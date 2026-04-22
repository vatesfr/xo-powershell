# SPDX-License-Identifier: Apache-2.0

function Import-XoVm
{
    <#
    .SYNOPSIS
        Import a VM file (.xva/.ova) into a pool.
    .DESCRIPTION
        Calls POST /pools/{id}/vms with the file contents as an application/octet-stream body. Large files are streamed from disk via Invoke-RestMethod's -InFile parameter. Returns a task object that can be passed to Wait-XoTask.
    .PARAMETER PoolUuid
        The UUID of the pool to import the VM into.
    .PARAMETER InFile
        Path to the .xva or .ova file on disk.
    .EXAMPLE
        Import-XoVm -PoolUuid "<pool>" -InFile "./mytemplate.xva"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    [OutputType("XoPowershell.Task")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string]$PoolUuid,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$InFile
    )

    begin
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }
    }

    process
    {
        $resolved = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($InFile)
        if (-not (Test-Path -LiteralPath $resolved))
        {
            throw "File not found: $resolved"
        }

        if (-not $PSCmdlet.ShouldProcess($PoolUuid, "import VM from $resolved"))
        {
            return
        }

        $uri = "$script:XoHost/rest/v0/pools/$PoolUuid/vms"
        Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters -ContentType "application/octet-stream" -InFile $resolved | ForEach-Object {
            if ($_ -is [string] -and $_ -match '\/rest\/v0\/tasks\/([0-9a-z]+)')
            {
                ConvertFrom-XoTaskHref $_
            }
            elseif ($_ -and $_.PSObject.Properties.Name -contains 'id')
            {
                Get-XoTask -TaskId $_.id
            }
            else
            {
                $_
            }
        }
    }
}

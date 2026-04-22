# SPDX-License-Identifier: Apache-2.0

function Import-XoSrVdi
{
    <#
    .SYNOPSIS
        Import a VDI file into a Xen Orchestra storage repository.
    .DESCRIPTION
        Calls POST /srs/{id}/vdis with the file contents as an application/octet-stream body. XO creates a VDI on the target SR and streams the uploaded content into it. Returns a task object that can be passed to Wait-XoTask.
    .PARAMETER SrUuid
        The UUID of the SR to import the VDI into.
    .PARAMETER InFile
        Path to the VDI file on disk (raw or vhd).
    .EXAMPLE
        Import-XoSrVdi -SrUuid "<sr>" -InFile "./disk.vhd"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    [OutputType("XoPowershell.Task")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string]$SrUuid,

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

        if (-not $PSCmdlet.ShouldProcess($SrUuid, "import VDI from $resolved"))
        {
            return
        }

        $uri = "$script:XoHost/rest/v0/srs/$SrUuid/vdis"
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

# SPDX-License-Identifier: Apache-2.0

function Import-XoVdi
{
    <#
    .SYNOPSIS
        Import content into an existing VDI.
    .DESCRIPTION
        Calls PUT /vdis/{id}.{format} to upload raw VDI content (raw or vhd) to a pre-existing VDI. Use New-XoVdi first to create an empty VDI of the correct size.
    .PARAMETER VdiUuid
        The UUID of the target VDI.
    .PARAMETER Format
        Upload format: 'raw' or 'vhd'.
    .PARAMETER InFile
        Path to the file to upload.
    .EXAMPLE
        Import-XoVdi -VdiUuid "<vdi>" -Format vhd -InFile "./disk.vhd"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string]$VdiUuid,

        [Parameter(Mandatory, Position = 1)]
        [ValidateSet("raw", "vhd")]
        [string]$Format,

        [Parameter(Mandatory, Position = 2)]
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

        if (-not $PSCmdlet.ShouldProcess($VdiUuid, "import VDI content from $resolved ($Format)"))
        {
            return
        }

        $uri = "$script:XoHost/rest/v0/vdis/$VdiUuid.$Format"
        Invoke-RestMethod -Uri $uri -Method Put @script:XoRestParameters -ContentType "application/octet-stream" -InFile $resolved
    }
}

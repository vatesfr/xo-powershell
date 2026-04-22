# SPDX-License-Identifier: Apache-2.0

function Export-XoVmSnapshot
{
    <#
    .SYNOPSIS
        Export a Xen Orchestra VM snapshot to a local file.
    .DESCRIPTION
        Downloads the specified VM snapshot in either xva (XenServer native) or ova format. The download is streamed to -OutFile; nothing is returned unless -PassThru is specified. For large VM snapshots the export can take a while - consider running it as a background job.
    .PARAMETER VmSnapshotUuid
        The UUID of the VM snapshot to export.
    .PARAMETER Format
        Export format: 'xva' (XenServer native, fastest) or 'ova' (portable OVF).
    .PARAMETER OutFile
        Local path to write the exported file to. Parent directory must exist.
    .PARAMETER PassThru
        Return the written file as a FileInfo object.
    .EXAMPLE
        Export-XoVmSnapshot -VmSnapshotUuid "<uuid>" -Format xva -OutFile "./export.xva"
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string]$VmSnapshotUuid,

        [Parameter(Mandatory)]
        [ValidateSet("xva", "ova")]
        [string]$Format,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OutFile,

        [Parameter()]
        [switch]$PassThru
    )

    process
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }

        $resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutFile)

        if ($PSCmdlet.ShouldProcess($VmSnapshotUuid, "export to $resolvedPath in $Format format"))
        {
            try
            {
                $uri = "$script:XoHost/rest/v0/vm-snapshots/$VmSnapshotUuid.$Format"
                Invoke-RestMethod -Uri $uri @script:XoRestParameters -OutFile $resolvedPath

                if ($PassThru)
                {
                    Get-Item $resolvedPath
                }
            }
            catch
            {
                throw ("Failed to export VmSnapshot with UUID {0}: {1}" -f $VmSnapshotUuid, $_)
            }
        }
    }
}


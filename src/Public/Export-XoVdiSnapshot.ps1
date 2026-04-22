# SPDX-License-Identifier: Apache-2.0

function Export-XoVdiSnapshot
{
    <#
    .SYNOPSIS
        Export a VDI snapshot.
    .DESCRIPTION
        Export a VDI snapshot from Xen Orchestra. Downloads the snapshot to a local file.
    .PARAMETER VdiSnapshotUuid
        The UUID of the VDI snapshot to export.
    .PARAMETER Format
        The format to export the VDI snapshot in. Valid values: raw, vhd.
    .PARAMETER OutFile
        The path to save the exported VDI snapshot to.
    .PARAMETER PassThru
        If specified, returns the exported file info as a FileInfo object.
    .EXAMPLE
        Export-XoVdiSnapshot -VdiSnapshotUuid "12345678-abcd-1234-abcd-1234567890ab" -Format vhd -OutFile "C:\Exports\snapshot.vhd"
        Exports the VDI snapshot in VHD format to the specified file.
    .EXAMPLE
        Get-XoVdiSnapshot -VdiSnapshotUuid "12345678-abcd-1234-abcd-1234567890ab" | Export-XoVdiSnapshot -Format vhd -OutFile "C:\Exports\snapshot.vhd"
        Exports the VDI snapshot in VHD format to the specified file, piping from Get-XoVdiSnapshot.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias("VdiSnapshotId")]
        [string]$VdiSnapshotUuid,

        [Parameter(Mandatory)]
        [ValidateSet("raw", "vhd")]
        [string]$Format,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OutFile,

        [Parameter()]
        [switch]$PassThru
    )


    process
    {
        $resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutFile)

        if ($PSCmdlet.ShouldProcess($VdiSnapshotUuid, "export to $resolvedPath in $Format format"))
        {
            try
            {
                # swagger-canonical path: /vdi-snapshots/{id}.{format}
                $uri = "$script:XoHost/rest/v0/vdi-snapshots/$VdiSnapshotUuid.$Format"
                Invoke-RestMethod -Uri $uri @script:XoRestParameters -OutFile $resolvedPath

                if ($PassThru)
                {
                    Get-Item $resolvedPath
                }
            }
            catch
            {
                throw ("Failed to export VDI snapshot with UUID {0}: {1}" -f $VdiSnapshotUuid, $_)
            }
        }
    }
}

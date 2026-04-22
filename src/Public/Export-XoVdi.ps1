# SPDX-License-Identifier: Apache-2.0

function Export-XoVdi
{
    <#
    .SYNOPSIS
        Export a VDI.
    .DESCRIPTION
        Export a VDI from Xen Orchestra. Downloads the VDI to a local file.
    .PARAMETER VdiUuid
        The UUID of the VDI to export.
    .PARAMETER Format
        The format to export the VDI in. Valid values: raw, vhd.
    .PARAMETER OutFile
        The path to save the exported VDI to.
    .PARAMETER PassThru
        If specified, returns the exported file info as a FileInfo object.
    .EXAMPLE
        Export-XoVdi -VdiUuid "12345678-abcd-1234-abcd-1234567890ab" -Format vhd -OutFile "C:\Exports\disk.vhd"
        Exports the VDI in VHD format to the specified file.
    .EXAMPLE
        Get-XoVdi -VdiUuid "12345678-abcd-1234-abcd-1234567890ab" | Export-XoVdi -Format vhd -OutFile "C:\Exports\disk.vhd"
        Exports the VDI in VHD format to the specified file, piping from Get-XoVdi.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias("VdiId")]
        [string]$VdiUuid,

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
        if ($PSCmdlet.ShouldProcess($VdiUuid, "export to $OutFile in $Format format"))
        {
            try
            {
                # swagger-canonical path: /vdis/{id}.{format}
                $uri = "$script:XoHost/rest/v0/vdis/$VdiUuid.$Format"
                Invoke-RestMethod -Uri $uri @script:XoRestParameters -OutFile $OutFile

                if ($PassThru)
                {
                    Get-Item $OutFile
                }
            }
            catch
            {
                throw ("Failed to export VDI with UUID {0}: {1}" -f $VdiUuid, $_)
            }
        }
    }
}

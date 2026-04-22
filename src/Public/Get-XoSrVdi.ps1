# SPDX-License-Identifier: Apache-2.0

function Get-XoSrVdi
{
    <#
    .SYNOPSIS
        Get virtual disks (VDIs) scoped to a specific storage repository.
    .DESCRIPTION
        Returns the VDIs that live on the specified storage repository. The XO REST API does not expose a dedicated GET /srs/{id}/vdis endpoint (only POST for VDI uploads), so this cmdlet delegates to Get-XoVdi with the $SR filter. Accepts one or more SR UUIDs and pipeline input by property name.
    .PARAMETER SrUuid
        The UUID(s) of the storage repository whose virtual disks (VDIs) should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoSrVdi -SrUuid "c787b75c-3e0d-70fa-d0c3-cbfd382d7e33"
    .EXAMPLE
        Get-XoSr | Get-XoSrVdi
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Vdi")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$SrUuid
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
        foreach ($id in $SrUuid)
        {
            Get-XoVdi -SrUuid $id
        }
    }
}

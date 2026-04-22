# SPDX-License-Identifier: Apache-2.0

function Get-XoSingleVdiSnapshotById
{
    <#
    .SYNOPSIS
    Get a VDI Snapshot by ID

    .DESCRIPTION
    Get a single VDI Snapshot from Xen Orchestra by UUID.

    .PARAMETER VdiSnapshotUuid
    Target VDI Snapshot UUID to retrieve.

    .PARAMETER Params
    Target VDI Snapshot request parameters hash.

    .EXAMPLE
    Get-XoSingleVdiSnapshotById -VdiSnapshotUuid '812b59e1-2682-43ef-acd4-808d3551b907'
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.VdiSnapshot")]
    param (
        [string]$VdiSnapshotUuid,
        [hashtable]$Params
    )
    process
    {

        try
        {
            Write-Verbose "Getting VDI snapshot with UUID $VdiSnapshotUuid"
            $uri = "$script:XoHost/rest/v0/vdi-snapshots/$VdiSnapshotUuid"
            $snapshotData = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $Params

            if ($snapshotData)
            {
                return ConvertTo-XoVdiSnapshotObject -InputObject $snapshotData
            }
        }
        catch
        {
            throw ("Failed to retrieve VDI snapshot with UUID {0}: {1}" -f $VdiSnapshotUuid, $_)
        }
        return $null
    }
}

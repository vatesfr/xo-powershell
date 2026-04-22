# SPDX-License-Identifier: Apache-2.0

$script:XO_VDI_SNAPSHOT_FIELDS = "name_label,size,uuid,snapshot_time,snapshot_of,sr_uuid,usage"

function ConvertTo-XoVdiSnapshotObject
{
    <#
    .SYNOPSIS
        Convert a VDI snapshot object from the API to a PowerShell object.
    .DESCRIPTION
        Convert a VDI snapshot object from the API to a PowerShell object with proper properties.
    .PARAMETER InputObject
        The VDI snapshot object from the API.
    .EXAMPLE
        ConvertTo-XoSnapshotObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.VdiSnapshot")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [PSObject] $InputObject
    )

    process
    {
        $props = @{
            PSTypeName      = "XoPowershell.VdiSnapshot"
            VdiSnapshotUuid = $InputObject.uuid
            Name            = $InputObject.name_label
            Size            = $InputObject.size
            SnapshotOf      = $InputObject.snapshot_of
            SnapshotTime    = $InputObject.snapshot_time
            SrUuid          = $InputObject.sr_uuid
            Usage           = $InputObject.usage
        }

        [PSCustomObject]$props
    }
}

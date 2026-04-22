# SPDX-License-Identifier: Apache-2.0

function Get-XoVdiSnapshotAlarm
{
    <#
    .SYNOPSIS
        Get alarms scoped to a specific VDI snapshot.
    .DESCRIPTION
        Retrieves alarms attached to the specified Xen Orchestra VDI snapshot. Accepts one or more VDI snapshot UUIDs; each is queried independently and the combined results are returned.
    .PARAMETER VdiSnapshotUuid
        The UUID(s) of the VDI snapshot whose alarms should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoVdiSnapshotAlarm -VdiSnapshotUuid "00000000-0000-0000-0000-000000000000"
    .EXAMPLE
        Get-XoVdiSnapshot | Get-XoVdiSnapshotAlarm
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Alarm")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$VdiSnapshotUuid
    )

    begin
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }

        $params = @{}
        $params["fields"] = $script:XO_ALARM_FIELDS
    }

    process
    {
        foreach ($id in $VdiSnapshotUuid)
        {
            $uri = "$script:XoHost/rest/v0/vdi-snapshots/$id/alarms"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoAlarmObject
        }
    }
}


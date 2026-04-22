# SPDX-License-Identifier: Apache-2.0

function Get-XoNetworkAlarm
{
    <#
    .SYNOPSIS
        Get alarms scoped to a specific network.
    .DESCRIPTION
        Retrieves alarms attached to the specified Xen Orchestra network. Accepts one or more network UUIDs; each is queried independently and the combined results are returned.
    .PARAMETER NetworkUuid
        The UUID(s) of the network whose alarms should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoNetworkAlarm -NetworkUuid "00000000-0000-0000-0000-000000000000"
    .EXAMPLE
        Get-XoNetwork | Get-XoNetworkAlarm
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Alarm")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$NetworkUuid
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
        foreach ($id in $NetworkUuid)
        {
            $uri = "$script:XoHost/rest/v0/networks/$id/alarms"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoAlarmObject
        }
    }
}


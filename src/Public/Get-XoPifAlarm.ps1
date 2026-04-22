# SPDX-License-Identifier: Apache-2.0

function Get-XoPifAlarm
{
    <#
    .SYNOPSIS
        Get alarms scoped to a specific PIF.
    .DESCRIPTION
        Retrieves alarms attached to the specified Xen Orchestra PIF. Accepts one or more PIF UUIDs; each is queried independently and the combined results are returned.
    .PARAMETER PifUuid
        The UUID(s) of the PIF whose alarms should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoPifAlarm -PifUuid "00000000-0000-0000-0000-000000000000"
    .EXAMPLE
        Get-XoPif | Get-XoPifAlarm
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Alarm")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$PifUuid
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
        foreach ($id in $PifUuid)
        {
            $uri = "$script:XoHost/rest/v0/pifs/$id/alarms"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoAlarmObject
        }
    }
}


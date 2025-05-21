# SPDX-License-Identifier: Apache-2.0

$script:XO_ALARM_FIELDS = "body,name,time,type,uuid,`$pool"

function ConvertTo-XoAlarmObject {
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process {
        $props = @{
            AlarmTime = [System.DateTimeOffset]::FromUnixTimeSeconds($InputObject.time).ToLocalTime()
            BodyName  = $InputObject.body.name
            BodyValue = $InputObject.body.value
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Alarm -Properties $props
    }
}

function Get-XoAlarm {
    <#
    .SYNOPSIS
        List or query alarms.
    .DESCRIPTION
        Get Xen Orchestra alarms by UUID or list all existing alarms.
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    param (
        # UUIDs of alarms to query.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "AlarmUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$AlarmUuid,

        # Find alarms that match the specified body name.
        [Parameter(ParameterSetName = "Filter")]
        [string]$BodyName,

        # Filter to apply to the alarm query.
        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "PoolUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string]$PoolUuid,

        # Maximum number of results to return.
        [Parameter()]
        [int]$Limit = $script:XoSessionLimit
    )

    begin {
        $params = @{
            fields = $script:XO_ALARM_FIELDS
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "AlarmUuid") {
            foreach ($id in $AlarmUuid) {
                ConvertTo-XoAlarmObject (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/alarms/$id" @script:XoRestParameters -Body $params)
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq "Filter") {
            $AllFilters = $Filter

            if ($BodyName) {
                $AllFilters = "$AllFilters body:name:`"$BodyName`""
            }

            if ($AllFilters) {
                $params["filter"] = $AllFilters
            }

            if ($Limit) {
                $params["limit"] = $Limit
            }

            # the parentheses forces the resulting array to unpack, don't remove them!
            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/alarms" @script:XoRestParameters -Body $params) | ConvertTo-XoAlarmObject
        }
        elseif ($PSCmdlet.ParameterSetName -eq "PoolUuid") {
            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/pools/$PoolUuid/alarms" @script:XoRestParameters -Body $params) | ConvertTo-XoAlarmObject
        }
    }
}

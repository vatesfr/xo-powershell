# SPDX-License-Identifier: Apache-2.0

$script:XO_SCHEDULE_FIELDS = "cron,enabled,name,timezone,id,jobId"

function ConvertTo-XoScheduleObject {
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process {
        $props = @{
            ScheduleId = $InputObject.id
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Schedule -Properties $props
    }
}

function Get-XoSchedule {
    <#
    .SYNOPSIS
        List or query schedules.
    .DESCRIPTION
        Get Xen Orchestra schedules by UUID or list all existing schedules.
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    param (
        # UUIDs of schedules to query.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "ScheduleUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$ScheduleUuid,

        # Filter to apply to the schedule query.
        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        # Maximum number of results to return.
        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit = $script:XoSessionLimit
    )

    begin {
        $params = @{
            fields = $script:XO_SCHEDULE_FIELDS
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "ScheduleUuid") {
            foreach ($id in $ScheduleUuid) {
                ConvertTo-XoScheduleObject (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/schedules/$id" @script:XoRestParameters -Body $params)
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq "Filter") {
            $AllFilters = $Filter

            if ($AllFilters) {
                $params["filter"] = $AllFilters
            }

            if ($Limit) {
                $params["limit"] = $Limit
            }

            # the parentheses forces the resulting array to unpack, don't remove them!
            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/schedules" @script:XoRestParameters -Body $params) | ConvertTo-XoScheduleObject
        }
        elseif ($PSCmdlet.ParameterSetName -eq "PoolUuid") {
            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/pools/$PoolUuid/schedules" @script:XoRestParameters -Body $params) | ConvertTo-XoScheduleObject
        }
    }
}

function Start-XoSchedule {
    <#
    .SYNOPSIS
        Start one or more schedules.
    .DESCRIPTION
        Starts the specified schedules. Returns a task object that can be used to monitor
        the startup operation.
    .PARAMETER ScheduleId
        The ID(s) of the schedule(s) to start.
    .EXAMPLE
        Start-XoSchedule -ScheduleId "12345678-abcd-1234-abcd-1234567890ab"
        Starts the schedule with the specified ID.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ScheduleId
    )

    process {
        foreach ($id in $ScheduleId) {
            if ($PSCmdlet.ShouldProcess($id, "start")) {
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/schedules/$id/run" -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}

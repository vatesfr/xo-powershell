# SPDX-License-Identifier: Apache-2.0

function Get-XoSchedule
{
    <#
    .SYNOPSIS
        List or query schedules.
    .DESCRIPTION
        Get Xen Orchestra schedules by UUID or list all existing schedules.
    .PARAMETER ScheduleUuid
        The UUID(s) of the schedule(s) to retrieve.
    .PARAMETER Filter
        Custom filter expression for the schedule query.
    .PARAMETER Limit
        Maximum number of schedules to return.
    .EXAMPLE
        Get-XoSchedule -ScheduleUuid "12345678-abcd-1234-abcd-1234567890ab"
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

    begin
    {
        $params = @{
            fields = $script:XO_SCHEDULE_FIELDS
        }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "ScheduleUuid")
        {
            foreach ($id in $ScheduleUuid)
            {
                ConvertTo-XoScheduleObject (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/schedules/$id" @script:XoRestParameters -Body $params)
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            $AllFilters = $Filter

            if ($AllFilters)
            {
                $params["filter"] = $AllFilters
            }

            if ($Limit)
            {
                $params["limit"] = $Limit
            }

            # the parentheses forces the resulting array to unpack, don't remove them!
            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/schedules" @script:XoRestParameters -Body $params) | ConvertTo-XoScheduleObject
        }
    }
}

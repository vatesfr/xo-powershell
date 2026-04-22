# SPDX-License-Identifier: Apache-2.0

function Start-XoSchedule
{
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

    process
    {
        foreach ($id in $ScheduleId)
        {
            if ($PSCmdlet.ShouldProcess($id, "start"))
            {
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/schedules/$id/actions/run" -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}

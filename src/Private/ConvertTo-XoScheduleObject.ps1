# SPDX-License-Identifier: Apache-2.0

$script:XO_SCHEDULE_FIELDS = "cron,enabled,name,timezone,id,jobId"

function ConvertTo-XoScheduleObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo Schedule object

    .DESCRIPTION
    Convert api object to powershell xo Schedule object

    .PARAMETER InputObject
    Schedule input object from the API.

    .EXAMPLE
    ConvertTo-XoScheduleObject -InputObject $object

    #>
    [Cmdletbinding()]
    [OutputType("XoPowershell.Schedule")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            ScheduleId = $InputObject.id
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Schedule -Properties $props
    }
}

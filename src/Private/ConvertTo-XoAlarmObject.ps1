# SPDX-License-Identifier: Apache-2.0

$script:XO_ALARM_FIELDS = "body,name,time,type,uuid,`$pool"

function ConvertTo-XoAlarmObject
{
    <#
    .SYNOPSIS
    Convert object to Alarm Object

    .DESCRIPTION
    Convert an API response to an XO alarm object.

    .PARAMETER InputObject
    Alarm object returned from the API.

    .EXAMPLE
    ConvertTo-XoAlarmObject -InputObject $Object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Alarm")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            AlarmTime = [System.DateTimeOffset]::FromUnixTimeSeconds($InputObject.time).ToLocalTime()
            BodyName  = $InputObject.body.name
            BodyValue = $InputObject.body.value
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Alarm -Properties $props
    }
}

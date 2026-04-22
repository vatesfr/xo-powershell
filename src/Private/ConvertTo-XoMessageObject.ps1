# SPDX-License-Identifier: Apache-2.0

$script:XO_MESSAGE_FIELDS = "body,name,time,type,uuid"

function ConvertTo-XoMessageObject
{
    <#
    .SYNOPSIS
    Convert Message object into powershell object

    .DESCRIPTION
    Convert Message object into powershell object

    .PARAMETER InputObject
    Message object returned from the API.

    .EXAMPLE
    ConvertTo-XoMessageObject -InputObject $object

    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Message")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            MessageUuid = $InputObject.uuid
            MessageTime = [System.DateTimeOffset]::FromUnixTimeSeconds($InputObject.time).ToLocalTime()
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Message -Properties $props
    }
}

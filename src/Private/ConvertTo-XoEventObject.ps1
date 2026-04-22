# SPDX-License-Identifier: Apache-2.0

$script:XO_EVENT_FIELDS = "id,name,type,time"

function ConvertTo-XoEventObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo Event object

    .DESCRIPTION
    Convert an API response to an XO Event object.

    .PARAMETER InputObject
    Event input object from the API.

    .EXAMPLE
    ConvertTo-XoEventObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Event")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            EventId = $InputObject.id
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Event -Properties $props
    }
}

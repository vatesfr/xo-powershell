# SPDX-License-Identifier: Apache-2.0

$script:XO_PBD_FIELDS = "attached,id,uuid,device_config,host,SR"

function ConvertTo-XoPbdObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo Pbd object

    .DESCRIPTION
    Convert an API response to an XO Pbd object.

    .PARAMETER InputObject
    Pbd input object from the API.

    .EXAMPLE
    ConvertTo-XoPbdObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Pbd")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            PbdUuid = $InputObject.uuid
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Pbd -Properties $props
    }
}

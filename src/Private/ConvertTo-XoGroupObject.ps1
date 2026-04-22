# SPDX-License-Identifier: Apache-2.0

$script:XO_GROUP_FIELDS = "id,name,users"

function ConvertTo-XoGroupObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo Group object

    .DESCRIPTION
    Convert an API response to an XO Group object.

    .PARAMETER InputObject
    Group input object from the API.

    .EXAMPLE
    ConvertTo-XoGroupObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Group")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            GroupId = $InputObject.id
            Name = $InputObject.name
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Group -Properties $props
    }
}

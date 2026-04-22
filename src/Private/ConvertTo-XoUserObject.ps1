# SPDX-License-Identifier: Apache-2.0

$script:XO_USER_FIELDS = "id,name,email,permission,groups"

function ConvertTo-XoUserObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo User object

    .DESCRIPTION
    Convert an API response to an XO User object.

    .PARAMETER InputObject
    User input object from the API.

    .EXAMPLE
    ConvertTo-XoUserObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.User")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            UserId = $InputObject.id
            Name = $InputObject.name
        }
        Set-XoObject $InputObject -TypeName XoPowershell.User -Properties $props
    }
}

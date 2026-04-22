# SPDX-License-Identifier: Apache-2.0

function ConvertTo-XoUserAuthenticationTokenObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo UserAuthenticationToken object

    .DESCRIPTION
    Convert an API response to an XO UserAuthenticationToken object.

    .PARAMETER InputObject
    UserAuthenticationToken input object from the API.

    .EXAMPLE
    ConvertTo-XoUserAuthenticationTokenObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.UserAuthenticationToken")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            TokenId = $InputObject.id
            UserId = $InputObject.user_id
        }
        Set-XoObject $InputObject -TypeName XoPowershell.UserAuthenticationToken -Properties $props
    }
}

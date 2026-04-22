# SPDX-License-Identifier: Apache-2.0

function ConvertTo-XoStatObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo Stat object

    .DESCRIPTION
    Convert an API response to an XO Stat object.

    .PARAMETER InputObject
    Stat input object from the API.

    .EXAMPLE
    ConvertTo-XoStatObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Stat")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        Set-XoObject $InputObject -TypeName XoPowershell.Stat
    }
}

# SPDX-License-Identifier: Apache-2.0

function ConvertTo-XoDashboardObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo Dashboard object

    .DESCRIPTION
    Convert an API response to an XO Dashboard object.

    .PARAMETER InputObject
    Dashboard input object from the API.

    .EXAMPLE
    ConvertTo-XoDashboardObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Dashboard")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        Set-XoObject $InputObject -TypeName XoPowershell.Dashboard
    }
}

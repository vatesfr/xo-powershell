# SPDX-License-Identifier: Apache-2.0

function ConvertTo-XoGuiRouteObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo GuiRoute object

    .DESCRIPTION
    Convert an API response to an XO GuiRoute object.

    .PARAMETER InputObject
    GuiRoute input object from the API.

    .EXAMPLE
    ConvertTo-XoGuiRouteObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.GuiRoute")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        Set-XoObject $InputObject -TypeName XoPowershell.GuiRoute
    }
}

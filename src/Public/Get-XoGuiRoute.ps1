# SPDX-License-Identifier: Apache-2.0

function Get-XoGuiRoute
{
    <#
    .SYNOPSIS
        Get the Xen Orchestra GUI route table.
    .DESCRIPTION
        Retrieves the /gui-routes resource which maps GUI generation names (e.g. xo5, xo6) to their URL prefixes. This is mainly useful for tooling that needs to construct GUI deep links.
    .EXAMPLE
        Get-XoGuiRoute
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.GuiRoute")]
    param ()

    process
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }

        $uri = "$script:XoHost/rest/v0/gui-routes"
        ConvertTo-XoGuiRouteObject (Invoke-RestMethod -Uri $uri @script:XoRestParameters)
    }
}


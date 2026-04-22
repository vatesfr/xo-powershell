# SPDX-License-Identifier: Apache-2.0

function Get-XoDashboard
{
    <#
    .SYNOPSIS
        Get the Xen Orchestra global dashboard summary.
    .DESCRIPTION
        Retrieves the global dashboard object exposed at /dashboard: aggregate counters (nHosts, nPools), resource overview (cpus, memory, storage), pool connectivity status, and repository totals. Useful for a one-shot health snapshot of the XO deployment.
    .EXAMPLE
        Get-XoDashboard
    .EXAMPLE
        (Get-XoDashboard).resourcesOverview
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Dashboard")]
    param ()

    process
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }

        $uri = "$script:XoHost/rest/v0/dashboard"
        ConvertTo-XoDashboardObject (Invoke-RestMethod -Uri $uri @script:XoRestParameters)
    }
}


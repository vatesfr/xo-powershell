# SPDX-License-Identifier: Apache-2.0

function Test-XoPing
{
    <#
    .SYNOPSIS
        Test the reachability of the Xen Orchestra REST API.
    .DESCRIPTION
        Sends a GET to the /ping endpoint using the current session credentials. Returns $true on success (2xx) or $false on any failure (network error, auth error, non-2xx). Does not throw. Useful for quick health probes in monitoring scripts.
    .EXAMPLE
        if (-not (Test-XoPing)) { throw "XO API unreachable" }
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param ()

    if (-not $script:XoHost -or -not $script:XoRestParameters)
    {
        throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
    }

    try
    {
        $null = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/ping" @script:XoRestParameters
        return $true
    }
    catch
    {
        Write-Verbose "Ping failed: $_"
        return $false
    }
}


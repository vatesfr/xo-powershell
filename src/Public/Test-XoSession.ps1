# SPDX-License-Identifier: Apache-2.0

$script:XO_DEFAULT_LIMIT = 25
$script:XoSessionLimit = $script:XO_DEFAULT_LIMIT

function Test-XoSession
{
    <#
    .SYNOPSIS
        Check the connection to Xen Orchestra.
    .DESCRIPTION
        Tests if the current session is connected to a Xen Orchestra instance.
    .EXAMPLE
        Test-XoSession
        Returns $true if connected, $false otherwise.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    # Test connection by attempting to get tasks with a minimal limit
    try
    {
        Get-XoTask -Limit 1 | Out-Null
        Write-Verbose "Successful connection to Xen Orchestra - $script:XoHost"
        return $true
    }
    catch
    {
        Write-Error "Xen Orchestra connection error - $script:XoHost $_"
        return $false
    }
}

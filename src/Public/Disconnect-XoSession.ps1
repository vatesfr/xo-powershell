# SPDX-License-Identifier: Apache-2.0

function Disconnect-XoSession
{
    <#
    .SYNOPSIS
        Disconnect from a Xen Orchestra instance.
    .DESCRIPTION
        Disconnects from the current Xen Orchestra session and optionally clears saved credentials.
    .PARAMETER ClearCredentials
        Clears any saved credentials for the current session.
    .EXAMPLE
        Disconnect-XoSession
        Disconnects from the current session.
    .EXAMPLE
        Disconnect-XoSession -ClearCredentials
        Disconnects from the current session and clears saved credentials.
    #>
    [CmdletBinding()]
    param (
        [Parameter()][switch]$ClearCredentials
    )
    if ($ClearCredentials -and $script:XoHost)
    {
        # TODO: clear saved token
    }
    $script:XoHost = $null
    $script:XoRestParameters = $null
    $script:XoSessionLimit = $script:XO_DEFAULT_LIMIT
}
New-Alias -Name Disconnect-XenOrchestra -Value Disconnect-XoSession

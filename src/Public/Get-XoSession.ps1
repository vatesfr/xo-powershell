# SPDX-License-Identifier: Apache-2.0

function Get-XoSession
{
    <#
    .SYNOPSIS
        Get the current XO session settings.
    .DESCRIPTION
        Get the current Xen Orchestra session settings.
    .EXAMPLE
        Get-XoSession
    #>
    [CmdletBinding()]
    param()

    [pscustomobject]@{
        Limit = $script:XoSessionLimit
    }
}

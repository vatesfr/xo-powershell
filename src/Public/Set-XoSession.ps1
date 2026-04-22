# SPDX-License-Identifier: Apache-2.0

function Set-XoSession
{
    <#
    .SYNOPSIS
        Set the current XO session settings.
    .DESCRIPTION
        Set the current Xen Orchestra session settings.
    .PARAMETER Limit
        Sets the current XO query limit for all Get-Xo* cmdlets that support a -Limit parameter.
    .EXAMPLE
        Set-XoSession -Limit 50
        Sets the current session-wide limit to 50 items for all query cmdlets.
    .EXAMPLE
        Set-XoSession -Limit 0
        Sets cmdlets to return all items by default.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'low')]
    param(
        [Parameter()]
        [int]$Limit
    )
    process
    {

        if ($PSBoundParameters.ContainsKey("Limit"))
        {
            if ($PSCmdlet.ShouldProcess($Limit, "Set updated limit"))
            {

                Write-Verbose "Default limit for XO queries changed from $script:XoSessionLimit to $Limit"
                $script:XoSessionLimit = $Limit
            }
        }
    }
}

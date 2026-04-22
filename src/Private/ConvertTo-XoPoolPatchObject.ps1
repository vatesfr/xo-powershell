# SPDX-License-Identifier: Apache-2.0

function ConvertTo-XoPoolPatchObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo PoolPatch object

    .DESCRIPTION
    Convert api object to powershell xo PoolPatch object

    .PARAMETER InputObject
    Pool patch input object from the API.

    .EXAMPLE
    ConvertTo-XoPoolPatchObject -InputObject $object

    #>
    [Cmdletbinding()]
    [OutputType("XoPowershell.PoolPatch")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            Date        = [System.DateTimeOffset]::FromUnixTimeSeconds($InputObject.changelog.date).ToLocalTime()
            Description = $InputObject.changelog.description
        }
        Set-XoObject $InputObject -TypeName XoPowershell.PoolPatch -Properties $props
    }
}

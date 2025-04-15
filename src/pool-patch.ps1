# SPDX-License-Identifier: Apache-2.0

function ConvertTo-XoPoolPatchObject {
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process {
        $props = @{
            Date        = [System.DateTimeOffset]::FromUnixTimeSeconds($InputObject.changelog.date).ToLocalTime()
            Description = $InputObject.changelog.description
        }
        Set-XoObject $InputObject -TypeName XoPowershell.PoolPatch -Properties $props
    }
}

function Get-XoPoolPatch {
    <#
    .SYNOPSIS
        Query pending patches for a Xen Orchestra pool.
    .DESCRIPTION
        Query pending patches for a Xen Orchestra pool.
    #>
    [CmdletBinding()]
    param (
        # UUID of pools to query.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string]$PoolUuid
    )

    (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/pools/$PoolUuid/missing_patches" @script:XoRestParameters -Body $params) | ConvertTo-XoPoolPatchObject
}

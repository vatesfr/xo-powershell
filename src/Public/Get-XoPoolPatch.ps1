# SPDX-License-Identifier: Apache-2.0

function Get-XoPoolPatch
{
    <#
    .SYNOPSIS
        Query pending patches for a Xen Orchestra pool.
    .DESCRIPTION
        Query pending patches for a Xen Orchestra pool.
    .PARAMETER PoolUuid
        Target Xen Orchestra pool UUID.
    .EXAMPLE
     Get-XoPoolPatch -PoolUuid '011ccf6a-c5ad-48ec-a255-d056584686f0'
    #>
    [CmdletBinding()]
    param (
        # UUID of pools to query.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string]$PoolUuid
    )
    process
    {

        (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/pools/$PoolUuid/missing_patches" @script:XoRestParameters -Body $params) | ConvertTo-XoPoolPatchObject
    }
}

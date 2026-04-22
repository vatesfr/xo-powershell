# SPDX-License-Identifier: Apache-2.0

function Get-XoPoolMessage
{
    <#
    .SYNOPSIS
    Get Pool message

    .DESCRIPTION
    Retrieves messages associated with a Xen Orchestra pool.

    .PARAMETER PoolUuid
    Target Xen Orchestra pool UUID.

    .EXAMPLE
    Get-XoPoolMessage -PoolUuid '011ccf6a-c5ad-48ec-a255-d056584686f0'
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string]$PoolUuid
    )
    process
    {

        (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/pools/$PoolUuid/messages" @script:XoRestParameters -Body $params) | ConvertFrom-XoUuidHref | ForEach-Object {
            Get-XoMessage $_
        }
    }
}

# SPDX-License-Identifier: Apache-2.0

function Get-XoPoolStat
{
    <#
    .SYNOPSIS
        Get performance statistics scoped to a specific pool.
    .DESCRIPTION
        Retrieves performance statistics attached to the specified Xen Orchestra pool. Accepts one or more pool UUIDs; each is queried independently and the combined results are returned.
    .PARAMETER PoolUuid
        The UUID(s) of the pool whose performance statistics should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoPoolStat -PoolUuid "b7569d99-30f8-178a-7d94-801de3e29b5b"
    .EXAMPLE
        Get-XoPool | Get-XoPoolStat
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Stat")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$PoolUuid
    )

    begin
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }

        $params = @{}

    }

    process
    {
        foreach ($id in $PoolUuid)
        {
            $uri = "$script:XoHost/rest/v0/pools/$id/stats"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoStatObject
        }
    }
}


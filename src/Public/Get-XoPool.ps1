# SPDX-License-Identifier: Apache-2.0

function Get-XoPool
{
    <#
    .SYNOPSIS
        Query pools by UUID or condition.
    .DESCRIPTION
        Get pool details. You can specify pools by their UUIDs or properties.
    .PARAMETER PoolUuid
        The UUID(s) of the pool(s) to retrieve.
    .PARAMETER Name
        Filter pools matching the specified name.
    .PARAMETER Filter
        Custom filter expression for the pool query.
    .PARAMETER Tag
        Filter pools matching any of the specified tags.
    .PARAMETER Limit
        Maximum number of pools to return.
    .EXAMPLE
        Get-XoPool -PoolUuid "12345678-abcd-1234-abcd-1234567890ab"
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    param (
        # UUIDs of pools to query.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "PoolUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$PoolUuid,

        # Find pools that match the specified name substring.
        [Parameter(ParameterSetName = "Filter")]
        [string]$Name,

        # Filter to apply to the pool query.
        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        # Find pools that match any of the specified tags.
        [Parameter(ParameterSetName = "Filter")]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tag,

        # Maximum number of results to return.
        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit = $script:XoSessionLimit
    )

    begin
    {
        $params = @{
            fields = $script:XO_POOL_FIELDS
        }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "PoolUuid")
        {
            foreach ($id in $PoolUuid)
            {
                ConvertTo-XoPoolObject (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/pools/$id" @script:XoRestParameters -Body $params)
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            $AllFilters = $Filter

            if ($Name)
            {
                $AllFilters = "$AllFilters name_label:`"$Name`""
            }

            if ($Tag)
            {
                $tags = ($tag | ForEach-Object { "`"$_`"" }) -join " "
                $AllFilters = "$AllFilters tags:($tags)"
            }

            if ($AllFilters)
            {
                $params["filter"] = $AllFilters
            }

            if ($Limit)
            {
                $params["limit"] = $Limit
            }

            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/pools" @script:XoRestParameters -Body $params) | ConvertTo-XoPoolObject
        }
    }
}

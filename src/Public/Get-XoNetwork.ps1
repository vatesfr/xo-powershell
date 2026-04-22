# SPDX-License-Identifier: Apache-2.0

function Get-XoNetwork
{
    <#
    .SYNOPSIS
        Query networks by UUID or condition.
    .DESCRIPTION
        Get network details. You can specify networks by their UUIDs or properties.
    .PARAMETER NetworkUuid
        The UUID(s) of the network(s) to retrieve.
    .PARAMETER Name
        Filter networks matching the specified name.
    .PARAMETER Filter
        Custom filter expression for the network query.
    .PARAMETER Tag
        Filter networks matching any of the specified tags.
    .PARAMETER Limit
        Maximum number of networks to return.
    .EXAMPLE
        Get-XoNetwork -NetworkUuid "12345678-abcd-1234-abcd-1234567890ab"
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    param (
        # UUIDs of networks to query.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "NetworkUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$NetworkUuid,

        # Find networks that match the specified name substring.
        [Parameter(ParameterSetName = "Filter")]
        [string]$Name,

        # Filter to apply to the network query.
        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        # Find networks that match any of the specified tags.
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
            fields = $script:XO_NETWORK_FIELDS
        }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "NetworkUuid")
        {
            foreach ($id in $NetworkUuid)
            {
                ConvertTo-XoNetworkObject (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/networks/$id" @script:XoRestParameters -Body $params)
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

            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/networks" @script:XoRestParameters -Body $params) | ConvertTo-XoNetworkObject
        }
    }
}

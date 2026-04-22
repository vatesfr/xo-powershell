# SPDX-License-Identifier: Apache-2.0

function Get-XoVif
{
    <#
    .SYNOPSIS
        Query VIFs by UUID or condition.
    .DESCRIPTION
        Get VIF details. You can specify VIFs by their UUIDs or properties.
    .PARAMETER VifUuid
        The UUID(s) of the VIF(s) to retrieve.
    .PARAMETER Name
        Filter VIFs matching the specified name.
    .PARAMETER Filter
        Custom filter expression for the VIF query.
    .PARAMETER Tag
        Filter VIFs matching any of the specified tags.
    .PARAMETER Limit
        Maximum number of VIFs to return.
    .EXAMPLE
        Get-XoVif -VifUuid "12345678-abcd-1234-abcd-1234567890ab"
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    param (
        # UUIDs of VIFs to query.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "VifUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [Alias("VIFs")]
        [string[]]$VifUuid,

        # Find VIFs that match the specified name substring.
        [Parameter(ParameterSetName = "Filter")]
        [string]$Name,

        # Filter to apply to the VIF query.
        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        # Find VIFs that match any of the specified tags.
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
            fields = $script:XO_VIF_FIELDS
        }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "VifUuid")
        {
            foreach ($id in $VifUuid)
            {
                ConvertTo-XoVifObject (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vifs/$id" @script:XoRestParameters -Body $params)
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

            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vifs" @script:XoRestParameters -Body $params) | ConvertTo-XoVifObject
        }
    }
}

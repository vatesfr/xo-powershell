# SPDX-License-Identifier: Apache-2.0

function Get-XoPif
{
    <#
    .SYNOPSIS
        Query PIFs by UUID or condition.
    .DESCRIPTION
        Get PIF details. You can specify PIFs by their UUIDs or properties.
    .PARAMETER PifUuid
        The UUID(s) of the PIF(s) to retrieve.
    .PARAMETER Name
        Filter PIFs matching the specified name.
    .PARAMETER Filter
        Custom filter expression for the PIF query.
    .PARAMETER Tag
        Filter PIFs matching any of the specified tags.
    .PARAMETER Limit
        Maximum number of PIFs to return.
    .EXAMPLE
        Get-XoPif -PifUuid "12345678-abcd-1234-abcd-1234567890ab"
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    param (
        # UUIDs of PIFs to query.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "PifUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [Alias("PIFs")]
        [string[]]$PifUuid,

        # Find PIFs that match the specified name substring.
        [Parameter(ParameterSetName = "Filter")]
        [string]$Name,

        # Filter to apply to the PIF query.
        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        # Find PIFs that match any of the specified tags.
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
            fields = $script:XO_PIF_FIELDS
        }

        if ($Limit)
        {
            $params["limit"] = $Limit
        }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "PifUuid")
        {
            foreach ($id in $PifUuid)
            {
                ConvertTo-XoPifObject (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/pifs/$id" @script:XoRestParameters -Body $params)
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

            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/pifs" @script:XoRestParameters -Body $params) | ConvertTo-XoPifObject
        }
    }
}

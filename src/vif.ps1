# SPDX-License-Identifier: Apache-2.0

$script:XO_VIF_FIELDS = "allowedIpv4Addresses,allowedIpv6Addresses,attached,device,lockingMode,MAC,MTU,txChecksumming,uuid,`$network,`$pool"

function ConvertTo-XoVifObject {
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process {
        $props = @{
            VifUuid     = $InputObject.uuid
            Name        = $InputObject.name_label
            Description = $InputObject.name_description
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Vif -Properties $props
    }
}

function Get-XoVif {
    <#
    .SYNOPSIS
        Query VIFs by UUID or condition.
    .DESCRIPTION
        Get VIF details. You can specify VIFs by their UUIDs or properties.
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

    begin {
        $params = @{
            fields = $script:XO_VIF_FIELDS
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "VifUuid") {
            foreach ($id in $VifUuid) {
                ConvertTo-XoVifObject (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vifs/$id" @script:XoRestParameters -Body $params)
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq "Filter") {
            $AllFilters = $Filter

            if ($Name) {
                $AllFilters = "$AllFilters name_label:`"$Name`""
            }

            if ($Tag) {
                $tags = ($tag | ForEach-Object { "`"$_`"" }) -join " "
                $AllFilters = "$AllFilters tags:($tags)"
            }

            if ($AllFilters) {
                $params["filter"] = $AllFilters
            }

            if ($Limit) {
                $params["limit"] = $Limit
            }

            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vifs" @script:XoRestParameters -Body $params) | ConvertTo-XoVifObject
        }
    }
}

function Set-XoVif {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias("VifId")]
        [string]$VifUuid,

        [Parameter()]
        [string]$Name,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [string[]]$Tags
    )

    $params = @{}

    if ($PSBoundParameters.ContainsKey("Name")) {
        $params["name_label"] = $Name
    }
    if ($PSBoundParameters.ContainsKey("Description")) {
        $params["name_description"] = $Description
    }
    if ($PSBoundParameters.ContainsKey("Tags")) {
        $params["tags"] = $Tags
    }

    if ($params.Count -gt 0) {
        $body = [System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json $params))
        Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vifs/$VifUuid" @script:XoRestParameters -Method Patch -ContentType "application/json" -Body $body
    }
}

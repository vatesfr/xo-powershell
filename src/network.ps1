# SPDX-License-Identifier: Apache-2.0

$script:XO_NETWORK_FIELDS = "automatic,defaultIsLocked,MTU,name_description,name_label,tags,PIFs,VIFs,nbd,uuid,`$pool"

function ConvertTo-XoNetworkObject {
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process {
        $props = @{
            NetworkUuid = $InputObject.uuid
            Name        = $InputObject.name_label
            Description = $InputObject.name_description
            PifUuid     = $InputObject.PIFs
            VifUuid     = $InputObject.VIFs
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Network -Properties $props
    }
}

function Get-XoNetwork {
    <#
    .SYNOPSIS
        Query networks by UUID or condition.
    .DESCRIPTION
        Get network details. You can specify networks by their UUIDs or properties.
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

    begin {
        $params = @{
            fields = $script:XO_NETWORK_FIELDS
        }

        if ($PSCmdlet.ParameterSetName -eq "Filter") {
            $AllFilters = $Filter

            if ($Name) {
                $AllFilters = "$AllFilters name_label:`"$Name`""
            }

            if ($Tag) {
                $tags = ($tag | ForEach-Object { "`"$_`"" }) -join " "
                $AllFilters = "$AllFilters tags:($tags)"
            }

            $params = Remove-XoEmptyValues @{
                filter = $AllFilters
                fields = $script:XO_NETWORK_FIELDS
            }
        }

        if ($Limit) {
            $params["limit"] = $Limit
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "NetworkUuid") {
            foreach ($id in $NetworkUuid) {
                ConvertTo-XoNetworkObject (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/networks/$id" @script:XoRestParameters -Body $params)
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq "Filter") {
            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/networks" @script:XoRestParameters -Body $params) | ConvertTo-XoNetworkObject
        }
    }
}

function Set-XoNetwork {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias("NetworkId")]
        [string]$NetworkUuid,

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
        Invoke-RestMethod -Uri "$script:XoHost/rest/v0/networks/$NetworkUuid" @script:XoRestParameters -Method Patch -ContentType "application/json" -Body $body
    }
}

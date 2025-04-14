# SPDX-License-Identifier: Apache-2.0

$script:XO_PIF_FIELDS = "attached,isBondMaster,isBondSlave,device,deviceName,dns,disallowUnplug,gateway,ip,ipv6,mac,management,carrier,mode,ipv6Mode,mtu,netmask,physical,primaryAddressType,vlan,speed,uuid,`$network,`$pool"

function ConvertTo-XoPifObject {
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process {
        $props = @{
            PifUuid     = $InputObject.uuid
            Name        = $InputObject.name_label
            Description = $InputObject.name_description
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Pif -Properties $props
    }
}

function Get-XoPif {
    <#
    .SYNOPSIS
        Query PIFs by UUID or condition.
    .DESCRIPTION
        Get PIF details. You can specify PIFs by their UUIDs or properties.
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

    begin {
        $params = @{
            fields = $script:XO_PIF_FIELDS
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
                fields = $script:XO_PIF_FIELDS
            }
        }

        if ($Limit) {
            $params["limit"] = $Limit
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "PifUuid") {
            foreach ($id in $PifUuid) {
                ConvertTo-XoPifObject (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/pifs/$id" @script:XoRestParameters -Body $params)
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq "Filter") {
            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/pifs" @script:XoRestParameters -Body $params) | ConvertTo-XoPifObject
        }
    }
}

function Set-XoPif {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias("PifId")]
        [string]$PifUuid,

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
        Invoke-RestMethod -Uri "$script:XoHost/rest/v0/pifs/$PifUuid" @script:XoRestParameters -Method Patch -ContentType "application/json" -Body $body
    }
}

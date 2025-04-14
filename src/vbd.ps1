# SPDX-License-Identifier: Apache-2.0

$script:XO_VBD_FIELDS = "attached,bootable,device,is_cd_drive,position,read_only,uuid,`$pool"

function ConvertTo-XoVbdObject {
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process {
        $props = @{
            VbdUuid     = $InputObject.uuid
            IsCdDrive   = $InputObject.is_cd_drive
            ReadOnly    = $InputObject.read_only
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Vbd -Properties $props
    }
}

function Get-XoVbd {
    <#
    .SYNOPSIS
        Query VBDs by UUID or condition.
    .DESCRIPTION
        Get VBD details. You can specify VBDs by their UUIDs or properties.
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    param (
        # UUIDs of VBDs to query.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "VbdUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [Alias("`$VBDs")]
        [string[]]$VbdUuid,

        # Find VBDs that match the specified name substring.
        [Parameter(ParameterSetName = "Filter")]
        [string]$Name,

        # Filter to apply to the VBD query.
        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        # Find VBDs that match any of the specified tags.
        [Parameter(ParameterSetName = "Filter")]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tag,

        # Maximum number of results to return.
        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit = $script:XoSessionLimit
    )

    begin {
        $params = @{
            fields = $script:XO_VBD_FIELDS
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
                fields = $script:XO_VBD_FIELDS
            }
        }

        if ($Limit) {
            $params["limit"] = $Limit
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "VbdUuid") {
            foreach ($id in $VbdUuid) {
                ConvertTo-XoVbdObject (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vbds/$id" @script:XoRestParameters -Body $params)
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq "Filter") {
            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vbds" @script:XoRestParameters -Body $params) | ConvertTo-XoVbdObject
        }
    }
}

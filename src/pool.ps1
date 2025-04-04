$script:XO_POOL_FIELDS = "auto_poweron,default_SR,HA_enabled,haSrs,master,tags,name_description,name_label,migrationCompression,cpus,zstdSupported,vtpmSupported,platform_version,type,uuid"

function ConvertTo-XoPoolObject {
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process {
        $props = @{
            PoolUuid        = $InputObject.uuid
            Name            = $InputObject.name_label
            CpuCores        = $InputObject.cpus.cores
            PlatformVersion = $InputObject.platform_version
            HAEnabled       = $InputObject.HA_enabled
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Pool -Properties $props
    }
}

function Get-XoPool {
    <#
    .SYNOPSIS
        Query pools by UUID or condition.
    .DESCRIPTION
        Get pool details. You can specify pools by their UUIDs or properties.
    .PARAMETER PoolUuid
        UUIDs of pools to query.
    .PARAMETER Name
        Find pools that match the specified name substring.
    .PARAMETER Tag
        Find pools that match any of the specified tags.
    .PARAMETER Limit
        Maximum number of results to return.
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "PoolUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$PoolUuid,

        [Parameter(ParameterSetName = "Filter")]
        [string]$Name,

        [Parameter(ParameterSetName = "Filter")]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tag,

        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit
    )

    begin {
        $params = @{
            fields = $script:XO_POOL_FIELDS
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "PoolUuid") {
            foreach ($id in $PoolUuid) {
                ConvertTo-XoPoolObject (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/pools/$id" @script:XoRestParameters -Body $params)
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq "Filter") {
            $filter = ""

            if ($Name) {
                $filter = "$filter name_label:`"$Name`""
            }

            if ($Tag) {
                $tags = ($tag | ForEach-Object { "`"$_`"" }) -join " "
                $filter = "$filter tags:($tags)"
            }

            $params = Remove-XoEmptyValues @{
                filter = $filter
                fields = $script:XO_POOL_FIELDS
            }

            if ($Limit) {
                $params["limit"] = $Limit
            }

            # the parentheses forces the resulting array to unpack, don't remove them!
            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/pools" @script:XoRestParameters -Body $params) | ConvertTo-XoPoolObject
        }
    }
}

function Get-XoPoolMessage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string]$PoolUuid
    )

    (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/pools/$PoolUuid/messages" @script:XoRestParameters -Body $params) | ConvertFrom-XoUuidHref | ForEach-Object {
        Get-XoMessage $_
    }
}

# For convenience.
function Invoke-XoPoolAction {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$PoolUuid,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Action
    )

    process {
        foreach ($id in $PoolUuid) {
            Invoke-RestMethod -Uri "$script:XoHost/rest/v0/pools/$PoolUuid/actions/$Action" -Method Post @script:XoRestParameters | ForEach-Object {
                ConvertFrom-XoTaskHref $_
            }
        }
    }
}

function Restart-XoPool {
    <#
    .SYNOPSIS
        Restart a running pool.
    .DESCRIPTION
        Restart the specified pools using a rolling pool reboot.
    .PARAMETER PoolUuid
        The UUID(s) of the pools(s) to restart.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$PoolUuid
    )

    process {
        foreach ($id in $PoolUuid) {
            if ($PSCmdlet.ShouldProcess($id, "Rolling pool reboot")) {
                Invoke-XoPoolAction -PoolUuid $id -Action "rolling_reboot"
            }
        }
    }
}

function Stop-XoPool {
    <#
    .SYNOPSIS
        Stop a running pool.
    .DESCRIPTION
        Stop the specified pools. Currently only supports emergency shutdown.
    .PARAMETER PoolUuid
        The UUID(s) of the pools(s) to stop.
    .PARAMETER Force
        Perform an emergency shutdown.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$PoolUuid,

        [Parameter(Mandatory)]
        [switch]$Force
    )

    process {
        # Note: "Stop" is quite different from "emergency shutdown", thus the "-Force" parameter being mandatory for now.

        foreach ($id in $PoolUuid) {
            if ($PSCmdlet.ShouldProcess($id, "Emergency shutdown")) {
                Invoke-XoPoolAction -PoolUuid $id -Action "emergency_shutdown"
            }
        }
    }
}

function Update-XoPool {
    <#
    .SYNOPSIS
        Update a running pool.
    .DESCRIPTION
        Update the specified pools using a rolling pool update.
    .PARAMETER PoolUuid
        The UUID(s) of the pools(s) to update.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$PoolUuid
    )

    process {
        foreach ($id in $PoolUuid) {
            if ($PSCmdlet.ShouldProcess($id, "Rolling pool update")) {
                Invoke-XoPoolAction -PoolUuid $id -Action "rolling_update"
            }
        }
    }
}

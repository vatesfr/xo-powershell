# SPDX-License-Identifier: Apache-2.0

$script:XO_VM_FIELDS = "uuid,name_label,name_description,power_state,addresses,tags,memory,VIFs,snapshots,current_operations,auto_poweron,os_version,startTime,VCPUs_at_startup,CPUs,VCPUs_number,`$VBDs"

function ConvertTo-XoVmObject {
    <#
    .SYNOPSIS
        Convert a VM object from the API to a PowerShell object.
    .DESCRIPTION
        Convert a VM object from the API to a PowerShell object with proper properties and types.
    .PARAMETER InputObject
        The VM object from the API.
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Vm")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [PSObject] $InputObject
    )

    process {
        $props = @{
            VmUuid      = $InputObject.uuid
            Name        = $InputObject.name_label
            Description = $InputObject.name_description
            PowerState  = $InputObject.power_state
            OsVersion   = $InputObject.os_version
            Parent      = $InputObject.parent
            HostUuid    = $InputObject.$container
        }

        if ($InputObject.CPUs.number) {
            $props["CPUs"] = $InputObject.CPUs.number
        }
        elseif ($InputObject.CPUs.max) {
            $props["CPUs"] = $InputObject.CPUs.max
        }
        else {
            $props["CPUs"] = $null
        }

        Set-XoObject $InputObject -TypeName XoPowershell.Vm -Properties $props
    }
}

function Get-XoSingleVmById {
    param (
        [string]$VmUuid
    )

    try {
        $uri = "$script:XoHost/rest/v0/vms/$VmUuid"
        $params = @{ fields = $script:XO_VM_FIELDS }
        $vmData = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params

        if ($vmData) {
            return ConvertTo-XoVmObject -InputObject $vmData
        }
    }
    catch {
        throw ("Failed to retrieve VM with UUID {0}: {1}" -f $VmUuid, $_)
    }
    return $null
}

function Get-XoVm {
    <#
    .SYNOPSIS
        Get VMs from Xen Orchestra.
    .DESCRIPTION
        Retrieves VMs from Xen Orchestra. Can retrieve specific VMs by their UUID
        or filter VMs by power state, tags, or custom filters.
    .PARAMETER VmUuid
        The UUID(s) of the VM(s) to retrieve.
    .PARAMETER PowerState
        Filter VMs by power state. Valid values: Running, Halted, Suspended.
    .PARAMETER Tag
        Filter VMs by tag.
    .PARAMETER Filter
        Custom filter to apply to the VM query.
    .PARAMETER Limit
        Maximum number of results to return. Default is 25 if not specified.
    .EXAMPLE
        Get-XoVm
        Returns up to 25 VMs.
    .EXAMPLE
        Get-XoVm -Limit 0
        Returns all VMs without limit.
    .EXAMPLE
        Get-XoVm -VmUuid "12345678-abcd-1234-abcd-1234567890ab"
        Returns the VM with the specified UUID.
    .EXAMPLE
        Get-XoVm -PowerState Running
        Returns running VMs (up to default limit).
    .EXAMPLE
        Get-XoVm -Tag "Production"
        Returns VMs tagged with "Production" (up to default limit).
    .EXAMPLE
        Get-XoVm -Filter "name_label:test*"
        Returns VMs with names starting with "test" (up to default limit).
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "VmUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [Alias("VmId")]
        [string[]]$VmUuid,

        [Parameter(ParameterSetName = "Filter")]
        [ValidateSet("Running", "Halted", "Suspended")]
        [string[]]$PowerState,

        [Parameter(ParameterSetName = "Filter")]
        [string[]]$Tag,

        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Filter")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string]$PoolUuid,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Filter")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string]$HostUuid,

        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit = $script:XoSessionLimit
    )

    begin {
        if (-not $script:XoHost -or -not $script:XoRestParameters) {
            throw ("Not connected to Xen Orchestra. Call Connect-XoSession first.")
        }

        $params = @{ fields = $script:XO_VM_FIELDS }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "VmUuid") {
            foreach ($id in $VmUuid) {
                Get-XoSingleVmById -VmUuid $id
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq "Filter") {
            $AllFilters = $Filter

            if ($PowerState) {
                $AllFilters = "$AllFilters power_state:($($PowerState -join '|'))"
            }

            if ($Tag) {
                $AllFilters = "$AllFilters tags:($($Tag -join '&'))"
            }

            if ($PoolUuid) {
                $AllFilters = "$AllFilters `$pool:$PoolUuid"
            }

            if ($HostUuid) {
                $AllFilters = "$AllFilters `$container:$HostUuid"
            }

            if ($AllFilters) {
                Write-Verbose "Filter: $AllFilters"
                $params["filter"] = $AllFilters
            }

            if ($Limit) {
                $params['limit'] = $Limit
            }

            try {
                $uri = "$script:XoHost/rest/v0/vms"
                Write-Verbose "Getting VMs from $uri with parameters: $($params | ConvertTo-Json -Compress)"

                $response = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params

                if (!$response -or $response.Count -eq 0) {
                    Write-Verbose "No VMs found matching criteria"
                    return
                }

                Write-Verbose "Found $($response.Count) VMs"

                foreach ($vmItem in $response) {
                    ConvertTo-XoVmObject -InputObject $vmItem
                }
            }
            catch {
                throw ("Failed to list VMs. Error: {0}" -f $_)
            }
        }
    }
}

function Set-XoVm {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias("VmId")]
        [string]$VmUuid,

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
        Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$VmUuid" @script:XoRestParameters -Method Patch -ContentType "application/json" -Body $body
    }
}

function Get-XoVmVdi {
    <#
    .SYNOPSIS
        Get virtual disks attached to a VM.
    .DESCRIPTION
        Retrieves all virtual disk images (VDIs) attached to a specified VM.
    .PARAMETER VmUuid
        The UUID of the VM to get VDIs for.
    .EXAMPLE
        Get-XoVmVdi -VmUuid "12345678-abcd-1234-abcd-1234567890ab"
        Returns all virtual disks attached to the specified VM.
    .EXAMPLE
        Get-XoVm -PowerState Running | Get-XoVmVdi
        Returns all virtual disks attached to running VMs.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$VmUuid
    )

    begin {
        $params = @{
            fields = $script:XO_VDI_FIELDS
        }
    }

    process {
        foreach ($id in $VmUuid) {
            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$id/vdis" @script:XoRestParameters -Body $params) | ConvertTo-XoVdiObject
        }
    }
}

function Start-XoVm {
    <#
    .SYNOPSIS
        Start one or more VMs.
    .DESCRIPTION
        Starts the specified VMs. Returns a task object that can be used to monitor
        the startup operation.
    .PARAMETER VmUuid
        The UUID(s) of the VM(s) to start.
    .EXAMPLE
        Start-XoVm -VmUuid "12345678-abcd-1234-abcd-1234567890ab"
        Starts the VM with the specified UUID.
    .EXAMPLE
        Get-XoVm -PowerState Halted | Start-XoVm
        Starts all halted VMs.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$VmUuid
    )

    process {
        foreach ($id in $VmUuid) {
            if ($PSCmdlet.ShouldProcess($id, "start")) {
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$id/actions/start" -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}

function Stop-XoVm {
    <#
    .SYNOPSIS
        Stop one or more VMs.
    .DESCRIPTION
        Stops the specified VMs. By default, performs a clean shutdown.
        Use -Force to perform a hard shutdown.
    .PARAMETER VmUuid
        The UUID(s) of the VM(s) to stop.
    .PARAMETER Force
        If specified, performs a hard shutdown instead of a clean shutdown.
    .EXAMPLE
        Stop-XoVm -VmUuid "12345678-abcd-1234-abcd-1234567890ab"
        Performs a clean shutdown of the VM with the specified UUID.
    .EXAMPLE
        Get-XoVm -PowerState Running | Stop-XoVm -Force
        Performs a hard shutdown of all running VMs.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$VmUuid,
        [Parameter()][switch]$Force
    )

    begin {
        $action = if ($Force) { "hard_shutdown" } else { "clean_shutdown" }
    }

    process {
        foreach ($id in $VmUuid) {
            if ($PSCmdlet.ShouldProcess($id, $action)) {
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$id/actions/$action" -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}

function Restart-XoVm {
    <#
    .SYNOPSIS
        Restart one or more VMs.
    .DESCRIPTION
        Restarts the specified VMs. By default, performs a clean reboot.
        Use -Force to perform a hard reboot.
    .PARAMETER VmUuid
        The UUID(s) of the VM(s) to restart.
    .PARAMETER Force
        If specified, performs a hard reboot instead of a clean reboot.
    .EXAMPLE
        Restart-XoVm -VmUuid "12345678-abcd-1234-abcd-1234567890ab"
        Performs a clean reboot of the VM with the specified UUID.
    .EXAMPLE
        Get-XoVm -PowerState Running | Restart-XoVm -Force
        Performs a hard reboot of all running VMs.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$VmUuid,
        [Parameter()][switch]$Force
    )

    begin {
        $action = if ($Force) { "hard_reboot" } else { "clean_reboot" }
    }

    process {
        foreach ($id in $VmUuid) {
            if ($PSCmdlet.ShouldProcess($id, $action)) {
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$id/actions/$action" -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}

function Suspend-XoVm {
    <#
    .SYNOPSIS
        Suspend one or more VMs.
    .DESCRIPTION
        Suspends the specified VMs.
    .PARAMETER VmUuid
        The UUID(s) of the VM(s) to suspend.
    .EXAMPLE
        Suspend-XoVm -VmUuid "12345678-abcd-1234-abcd-1234567890ab"
        Suspends the VM with the specified UUID.
    .EXAMPLE
        Get-XoVm -PowerState Running | Suspend-XoVm
        Suspends all running VMs.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$VmUuid
    )

    process {
        foreach ($id in $VmUuid) {
            if ($PSCmdlet.ShouldProcess($id, "suspend")) {
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$id/actions/suspend" -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}

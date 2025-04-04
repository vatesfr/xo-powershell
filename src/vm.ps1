# SPDX-License-Identifier: Apache-2.0

$script:XO_VM_FIELDS = "name_label,name_description,power_state,uuid,addresses,tags,memory,VIFs,snapshots,current_operations,auto_poweron,os_version,startTime,VCPUs_at_startup,PV_drivers_version"

function ConvertTo-XoVmObject {
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process {
        $props = @{
            VmUuid      = $InputObject.uuid
            Name        = $InputObject.name_label
            Description = $InputObject.name_description
            PowerState  = $InputObject.power_state
            IpAddresses = ""
            MemorySize  = if ($InputObject.memory) { Format-XoSize $InputObject.memory.size } else { $null }
            CpuCount    = $InputObject.VCPUs_at_startup
            Tags        = $InputObject.tags
            SnapshotsCount = if ($InputObject.snapshots) { $InputObject.snapshots.Length } else { 0 }
            AutoPowerOn = $InputObject.auto_poweron
            OsVersion   = $InputObject.os_version.name
            StartTime   = if ($InputObject.startTime) { [System.DateTimeOffset]::FromUnixTimeSeconds($InputObject.startTime).ToLocalTime() } else { $null }
            PvDriversVersion = $InputObject.PV_drivers_version
        }
        if ($InputObject.power_state -ieq "Running") {
            $props["IpAddresses"] = $InputObject.addresses.PSObject.Properties | Where-Object MemberType -eq NoteProperty | Select-Object -ExpandProperty Value
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Vm -Properties $props
    }
}

function Get-XoVm {
    <#
    .SYNOPSIS
        Query VMs by UUID or condition.
    .DESCRIPTION
        Retrieves virtual machines from Xen Orchestra. Can retrieve specific VMs by their UUID
        or filter VMs by power state.
    .PARAMETER VmUuid
        The UUID(s) of the VM(s) to retrieve.
    .PARAMETER PowerState
        Filter VMs by power state. Can be "Halted", "Paused", "Running", or "Suspended".
    .PARAMETER Filter
        Custom filter to apply when searching for VMs.
    .PARAMETER Tag
        Filter VMs by tag.
    .PARAMETER Limit
        Maximum number of VMs to return.
    .EXAMPLE
        Get-XoVm
        Returns all VMs.
    .EXAMPLE
        Get-XoVm -VmUuid "12345678-abcd-1234-abcd-1234567890ab"
        Returns the VM with the specified UUID.
    .EXAMPLE
        Get-XoVm -PowerState Running
        Returns all running VMs.
    .EXAMPLE
        Get-XoVm -Tag "production"
        Returns all VMs with the "production" tag.
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    param (
        # UUIDs of VMs to query.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "VmUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$VmUuid,

        # Power states of VMs to query.
        [Parameter(ParameterSetName = "Filter")]
        [ValidateSet("Halted", "Paused", "Running", "Suspended")]
        [Alias("Status")]
        [string[]]$PowerState,

        # Custom filter to apply
        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        # Filter by tag
        [Parameter(ParameterSetName = "Filter")]
        [string[]]$Tag,

        # Limit number of results
        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit
    )

    begin {
        $params = @{
            fields = $script:XO_VM_FIELDS
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "VmUuid") {
            foreach ($id in $VmUuid) {
                ConvertTo-XoVmObject (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$id" @script:XoRestParameters -Body $params)
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq "Filter") {
            $filterParts = @()

            if ($PowerState) {
                $filterParts += "power_state:|($($PowerState -join ' '))"
            }

            if ($Tag) {
                $filterParts += "tags:|($($Tag -join ' '))"
            }

            if ($Filter) {
                $filterParts += $Filter
            }

            $combinedFilter = $filterParts -join " "

            $params = Remove-XoEmptyValues @{
                filter = $combinedFilter
                fields = $script:XO_VM_FIELDS
                limit = $Limit
            }

            # the parentheses forces the resulting array to unpack, don't remove them!
            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms" @script:XoRestParameters -Body $params) | ConvertTo-XoVmObject
        }
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

function New-XoVmSnapshot {
    <#
    .SYNOPSIS
        Create a snapshot of one or more VMs.
    .DESCRIPTION
        Creates a snapshot of the specified VMs. Optionally, you can specify a custom name
        for the snapshot.
    .PARAMETER VmUuid
        The UUID(s) of the VM(s) to snapshot.
    .PARAMETER SnapshotName
        The name to give to the snapshot. If not specified, a default name will be used.
    .PARAMETER NameLabel
        Alias for SnapshotName. The name to give to the snapshot.
    .EXAMPLE
        New-XoVmSnapshot -VmUuid "12345678-abcd-1234-abcd-1234567890ab"
        Creates a snapshot of the VM with the specified UUID.
    .EXAMPLE
        New-XoVmSnapshot -VmUuid "12345678-abcd-1234-abcd-1234567890ab" -SnapshotName "Before Update"
        Creates a snapshot named "Before Update" of the VM with the specified UUID.
    .EXAMPLE
        New-XoVmSnapshot -VmUuid "12345678-abcd-1234-abcd-1234567890ab" -NameLabel "Before Update"
        Creates a snapshot named "Before Update" of the VM with the specified UUID.
    .EXAMPLE
        Get-XoVm -PowerState Running | New-XoVmSnapshot -SnapshotName "Backup $(Get-Date -Format 'yyyy-MM-dd')"
        Creates a dated snapshot of all running VMs.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$VmUuid,

        [Parameter()]
        [Alias("NameLabel")]
        [string]$SnapshotName
    )

    begin {
        $params = Remove-XoEmptyValues @{
            name_label = $SnapshotName
        }
    }

    process {
        foreach ($id in $VmUuid) {
            if ($PSCmdlet.ShouldProcess($id, "snapshot")) {
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$id/actions/snapshot" -Method Post @script:XoRestParameters -Body $params | ForEach-Object {
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

function ConvertTo-XoVmSnapshotObject {
    <#
    .SYNOPSIS
        Convert a VM snapshot object from the API to a PowerShell object.
    .DESCRIPTION
        Convert a VM snapshot object from the API to a PowerShell object with proper properties.
    .PARAMETER InputObject
        The VM snapshot object from the API.
    #>
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process {
        $props = @{
            VmSnapshotUuid = $InputObject.uuid
            Name = $InputObject.name_label
            Description = $InputObject.name_description
            SnapshotTime = if ($InputObject.snapshot_time) { [System.DateTimeOffset]::FromUnixTimeSeconds($InputObject.snapshot_time).ToLocalTime() } else { $null }
            ParentVmUuid = $InputObject.snapshot_of
            PowerState = $InputObject.power_state
            Tags = $InputObject.tags
        }
        Set-XoObject $InputObject -TypeName XoPowershell.VmSnapshot -Properties $props
    }
}

function Get-XoVmSnapshot {
    <#
    .SYNOPSIS
        Get VM snapshots.
    .DESCRIPTION
        Retrieves VM snapshots from Xen Orchestra. Can retrieve specific snapshots by their ID
        or filter snapshots by various criteria.
    .PARAMETER SnapshotId
        The ID(s) of the snapshot(s) to retrieve.
    .PARAMETER Filter
        Filter to apply to the snapshot query.
    .PARAMETER Limit
        Maximum number of results to return.
    .EXAMPLE
        Get-XoVmSnapshot -SnapshotId "a1b2c3d4"
        Returns the VM snapshot with the specified ID.
    .EXAMPLE
        Get-XoVmSnapshot -Filter "name_label:backup"
        Returns all VM snapshots with "backup" in their name.
    #>
    [CmdletBinding(DefaultParameterSetName = "All")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "SnapshotId")]
        [ValidatePattern("[0-9a-z]+")]
        [Alias("VmSnapshotUuid")]
        [string[]]$SnapshotId,

        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "All")]
        [int]$Limit
    )

    begin {
        $fields = "name_label,name_description,uuid,snapshot_time,snapshot_of,power_state,tags"
        $params = Remove-XoEmptyValues @{
            fields = $fields
            filter = $Filter
            limit = $Limit
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "SnapshotId") {
            foreach ($id in $SnapshotId) {
                try {
                    Write-Verbose "Getting VM snapshot with ID $id"
                    $snapshotData = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vm-snapshots/$id" @script:XoRestParameters -Body $params
                    if ($snapshotData) {
                        ConvertTo-XoVmSnapshotObject $snapshotData
                    } else {
                        Write-Warning "No VM snapshot found with ID $id"
                    }
                }
                catch {
                    Write-Error "Failed to retrieve VM snapshot with ID $id. $_"
                }
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq "All" -or $PSCmdlet.ParameterSetName -eq "Filter") {
            try {
                Write-Verbose "Getting all VM snapshots"
                $response = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vm-snapshots" @script:XoRestParameters -Body $params

                if ($null -ne $response -and $response.Count -gt 0) {
                    Write-Verbose "Found $($response.Count) VM snapshot URLs"

                    $maxToProcess = if ($Limit -gt 0) { $Limit } else { $response.Count }
                    Write-Verbose "Will process up to $maxToProcess snapshots"

                    $processedCount = 0
                    foreach ($item in $response) {
                        if ($processedCount -ge $maxToProcess) { break }

                        try {
                            $id = $null

                            if ($item -is [string]) {
                                if ($item -match '\/vm-snapshots\/([^\/]+)(?:$|\?)') {
                                    $id = $matches[1]
                                    Write-Verbose "Extracted ID $id from URL $item"
                                }
                            }
                            elseif ($item.PSObject.Properties.Name -contains 'id') {
                                $id = $item.id
                                Write-Verbose "Found ID $id in object"
                            }
                            elseif ($item.PSObject.Properties.Name -contains 'uuid') {
                                $id = $item.uuid
                                Write-Verbose "Found UUID $id in object"
                            }

                            if ($id) {
                                $snapshotData = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vm-snapshots/$id" @script:XoRestParameters
                                if ($snapshotData) {
                                    ConvertTo-XoVmSnapshotObject $snapshotData
                                    $processedCount++
                                }
                            } else {
                                Write-Verbose "Could not extract ID from item: $item"
                            }
                        }
                        catch {
                            Write-Warning "Failed to process VM snapshot. $_"
                        }
                    }

                    Write-Verbose "Processed $processedCount VM snapshots"
                } else {
                    Write-Verbose "No VM snapshots found"
                }
            }
            catch {
                Write-Error "Failed to retrieve VM snapshots. $_"
            }
        }
    }
}

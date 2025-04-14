# SPDX-License-Identifier: Apache-2.0

$script:XO_VM_FIELDS = "uuid,name_label,name_description,power_state,addresses,tags,memory,VIFs,snapshots,current_operations,auto_poweron,os_version,startTime,VCPUs_at_startup,CPUs,VCPUs_number"

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
        $vmObj = [PSCustomObject]@{
            PSTypeName    = "XoPowershell.Vm"
            VmUuid        = $InputObject.uuid
            Name          = $InputObject.name_label
            Description   = $InputObject.name_description
            PowerState    = $InputObject.power_state
            MainIpAddress = $InputObject.mainIpAddress
            OsVersion     = $InputObject.os_version
            VIFs          = $InputObject.VIFs
            VBDs          = $InputObject.$VBDs
            Parent        = $InputObject.parent
            Snapshots     = $InputObject.snapshots
            HostUuid      = $InputObject.$container
            XenstoreData  = $InputObject.xenStoreData
            Tags          = $InputObject.tags
            Memory        = $InputObject.memory
        }

        if ($null -ne $InputObject.CPUs) {
            if ($InputObject.CPUs.PSObject.Properties.Name -contains 'number') {
                $vmObj | Add-Member -MemberType NoteProperty -Name CPUs -Value $InputObject.CPUs.number
            }
            elseif ($InputObject.CPUs.PSObject.Properties.Name -contains 'max') {
                $vmObj | Add-Member -MemberType NoteProperty -Name CPUs -Value $InputObject.CPUs.max
            }
        }

        return $vmObj
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
        [Alias("VmId")]
        [string[]]$VmUuid,

        [Parameter(ParameterSetName = "Filter")]
        [ValidateSet("Running", "Halted", "Suspended")]
        [string[]]$PowerState,

        [Parameter(ParameterSetName = "Filter")]
        [string[]]$Tag,

        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit = $script:XoSessionLimit
    )

    begin {
        if (-not $script:XoHost -or -not $script:XoRestParameters) {
            throw ("Not connected to Xen Orchestra. Call Connect-XoSession first.")
        }

        $params = @{ fields = $script:XO_VM_FIELDS }

        $filterParts = @()

        if ($PowerState) {
            $filterParts += "power_state:($($PowerState -join '|'))"
        }

        if ($Tag) {
            $filterParts += "tags:($($Tag -join '&'))"
        }

        if ($Filter) {
            $filterParts += $Filter
        }

        if ($filterParts.Count -gt 0) {
            $params['filter'] = $filterParts -join " "
        }

        if ($Limit -ne 0) {
            $params['limit'] = $Limit
            if (!$PSBoundParameters.ContainsKey('Limit')) {
                Write-Warning "No limit specified. Using default limit of $Limit. Use -Limit 0 for unlimited results."
            }
        }
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
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [PSObject] $InputObject
    )

    # Create object with direct properties from API
    $snapshotObj = [PSCustomObject]@{
        PSTypeName     = "XoPowershell.VmSnapshot"
        VmSnapshotUuid = $InputObject.uuid
        Name           = $InputObject.name_label
        Description    = $InputObject.name_description
        PowerState     = $InputObject.power_state
        SnapshotOf     = $InputObject.snapshot_of
        SnapshotTime   = $InputObject.snapshot_time
        Memory         = $InputObject.memory
    }

    if ($null -ne $InputObject.CPUs) {
        if ($InputObject.CPUs.PSObject.Properties.Name -contains 'number') {
            $snapshotObj | Add-Member -MemberType NoteProperty -Name CPUs -Value $InputObject.CPUs.number
        }
        elseif ($InputObject.CPUs.PSObject.Properties.Name -contains 'max') {
            $snapshotObj | Add-Member -MemberType NoteProperty -Name CPUs -Value $InputObject.CPUs.max
        }
    }

    return $snapshotObj
}

function Get-XoVmSnapshot {
    <#
    .SYNOPSIS
        Get VM snapshots.
    .DESCRIPTION
        Retrieves VM snapshots from Xen Orchestra. Can retrieve specific snapshots by their UUID
        or filter snapshots by various criteria.
    .PARAMETER VmSnapshotUuid
        The UUID(s) of the VM snapshot(s) to retrieve.
    .PARAMETER Filter
        Filter to apply to the snapshot query.
    .PARAMETER Limit
        Maximum number of results to return. Default is 25 if not specified.
    .EXAMPLE
        Get-XoVmSnapshot
        Returns up to 25 VM snapshots.
    .EXAMPLE
        Get-XoVmSnapshot -Limit 0
        Returns all VM snapshots without limit.
    .EXAMPLE
        Get-XoVmSnapshot -VmSnapshotUuid "12345678-abcd-1234-abcd-1234567890ab"
        Returns the VM snapshot with the specified UUID.
    .EXAMPLE
        Get-XoVmSnapshot -Filter "name_label:backup"
        Returns VM snapshots with "backup" in their name (up to default limit).
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "VmSnapshotUuid")]
        [ValidateNotNullOrEmpty()]
        [Alias("SnapshotId", "SnapshotUuid")]
        [string[]]$VmSnapshotUuid,

        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit = $script:XoSessionLimit
    )

    begin {
        if (-not $script:XoHost -or -not $script:XoRestParameters) {
            throw ("Not connected to Xen Orchestra. Call Connect-XoSession first.")
        }

        $fields = "uuid,name_label,name_description,snapshot_time,snapshot_of,power_state,tags,CPUs,memory"
        $params = @{ fields = $fields }

        if ($PSBoundParameters.ContainsKey('Filter')) {
            $params.filter = $Filter
        }

        if ($Limit -ne 0) {
            $params.limit = $Limit
            if (!$PSBoundParameters.ContainsKey('Limit')) {
                Write-Warning "No limit specified. Using default limit of $Limit. Use -Limit 0 for unlimited results."
            }
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "VmSnapshotUuid") {
            foreach ($id in $VmSnapshotUuid) {
                try {
                    Write-Verbose "Getting VM snapshot with UUID $id"
                    $snapshotData = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vm-snapshots/$id" @script:XoRestParameters
                    ConvertTo-XoVmSnapshotObject $snapshotData
                }
                catch {
                    throw ("Failed to retrieve VM snapshot with UUID {0}: {1}" -f $id, $_)
                }
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq "Filter") {
            try {
                $uri = "$script:XoHost/rest/v0/vm-snapshots"
                Write-Verbose "Getting VM snapshots from $uri with parameters: $($params | ConvertTo-Json -Compress)"

                $snapshotsResponse = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params

                if (!$snapshotsResponse -or $snapshotsResponse.Count -eq 0) {
                    Write-Verbose "No VM snapshots found matching criteria"
                    return
                }

                Write-Verbose "Found $($snapshotsResponse.Count) VM snapshots"

                foreach ($snapshotItem in $snapshotsResponse) {
                    ConvertTo-XoVmSnapshotObject $snapshotItem
                }
            }
            catch {
                throw ("Failed to list VM snapshots. Error: {0}" -f $_)
            }
        }
    }
}

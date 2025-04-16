# SPDX-License-Identifier: Apache-2.0

$script:XO_VM_SNAPSHOT_FIELDS = "uuid,name_label,name_description,snapshot_time,snapshot_of,power_state,tags,CPUs,memory"

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
        SnapshotTime   = [System.DateTimeOffset]::FromUnixTimeSeconds($InputObject.snapshot_time).ToLocalTime()
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
        [Alias("Snapshot")]
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

        $params = @{ fields = $script:XO_VM_SNAPSHOT_FIELDS }
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
            if ($Filter) {
                $params["filter"] = $Filter
            }

            if ($Limit) {
                $params["limit"] = $Limit
            }

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

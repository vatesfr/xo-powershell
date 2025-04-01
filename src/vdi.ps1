# SPDX-License-Identifier: Apache-2.0

$script:XO_VDI_FIELDS = "name_label,name_description,uuid,content_type,size,usage,physical_usage,snapshot_of,snapshots,sr,vbds,VMs,pool_master,tags"

function ConvertTo-XoVdiObject {
    <#
    .SYNOPSIS
        Convert VDI data from the API to a PowerShell object.
    .DESCRIPTION
        Converts virtual disk image (VDI) data from the Xen Orchestra API to a PowerShell custom object
        with properly typed properties.
    .PARAMETER InputObject
        The VDI data from the API to convert.
    .EXAMPLE
        $vdiData | ConvertTo-XoVdiObject
        Converts the VDI data to a PowerShell object.
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Vdi")]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        $props = @{
            PSTypeName = "XoPowershell.Vdi"
            VdiUuid = $InputObject.uuid
            Name = $InputObject.name_label
            Description = $InputObject.name_description
            Type = $InputObject.content_type
            Size = [long]$InputObject.size
            SizeHuman = Format-XoSize $InputObject.size
            Usage = [long]$InputObject.usage
            UsageHuman = Format-XoSize $InputObject.usage
            PhysicalUsage = [long]$InputObject.physical_usage
            PhysicalUsageHuman = Format-XoSize $InputObject.physical_usage
            SnapshotOf = $InputObject.snapshot_of
            Snapshots = $InputObject.snapshots
            StorageRepository = $InputObject.sr
            VirtualBlockDevices = $InputObject.vbds
            VirtualMachines = $InputObject.VMs
            Tags = $InputObject.tags
        }

        # Add pool master if available
        if ($InputObject.pool_master) {
            $props["PoolMaster"] = $InputObject.pool_master
        }

        [PSCustomObject]$props
    }
}

function Get-XoVdi {
    <#
    .SYNOPSIS
        Get VDIs from Xen Orchestra.
    .DESCRIPTION
        Retrieves virtual disk image (VDI) information from Xen Orchestra. Can retrieve all VDIs,
        a specific VDI by ID, or filter VDIs based on various criteria.
    .PARAMETER VdiId
        The ID of the VDI to retrieve.
    .PARAMETER SrUuid
        Filter VDIs by storage repository UUID.
    .PARAMETER Filter
        Custom filter string to apply to the API request.
    .PARAMETER Limit
        Limits the number of results returned.
    .EXAMPLE
        Get-XoVdi
        Returns all VDIs in Xen Orchestra.
    .EXAMPLE
        Get-XoVdi -VdiId "12345678-abcd-1234-abcd-1234567890ab"
        Returns the specific VDI.
    .EXAMPLE
        Get-XoVdi -SrUuid "12345678-abcd-1234-abcd-1234567890ab"
        Returns all VDIs on the specified storage repository.
    .EXAMPLE
        Get-XoVdi -Filter "name_label:backup"
        Returns all VDIs with "backup" in their name.
    #>
    [CmdletBinding(DefaultParameterSetName = "All")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "VdiId")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [Alias("id", "uuid")]
        [string[]]$VdiId,

        [Parameter(Mandatory, ParameterSetName = "SrFilter")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string]$SrUuid,

        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        [Parameter(ParameterSetName = "All")]
        [Parameter(ParameterSetName = "SrFilter")]
        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit
    )

    begin {
        Write-Verbose "Getting VDIs from XO"
<<<<<<< HEAD

        # Base parameters for API requests
=======
        
>>>>>>> b4b1752 (apply Tu's recommandation.)
        $params = Remove-XoEmptyValues @{
            fields = $script:XO_VDI_FIELDS
            filter = if ($PSCmdlet.ParameterSetName -eq "SrFilter") { "sr:$SrUuid" } elseif ($PSCmdlet.ParameterSetName -eq "Filter") { $Filter } else { $null }
            limit = $Limit
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "VdiId") {
            foreach ($id in $VdiId) {
                try {
                    Write-Verbose "Getting VDI with ID $id"
                    $vdi = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vdis/$id" @script:XoRestParameters -Body $params

                    if ($vdi) {
                        ConvertTo-XoVdiObject $vdi
                    }
                    else {
                        throw "No VDI found with ID $id"
                    }
                }
                catch {
                    throw "Failed to retrieve VDI with ID $id. Error: $_"
                }
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -ne "VdiId") {
            try {
                Write-Verbose "Getting all VDIs"
                $response = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vdis" @script:XoRestParameters -Body $params

                if ($null -ne $response -and $response.Count -gt 0) {
                    Write-Verbose "Found $($response.Count) VDI entries"

                    foreach ($item in $response) {
                        if ($item -is [string] -and $item -match '/vdis/([^/?]+)') {
                            $id = $matches[1]
                            Write-Verbose "Extracted VDI ID: $id"
                            $vdiData = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vdis/$id" @script:XoRestParameters
                            if ($vdiData) {
                                ConvertTo-XoVdiObject $vdiData
                            }
                        }
                        elseif ($item -is [System.Management.Automation.PSObject]) {
                            ConvertTo-XoVdiObject $item
                        }
                    }
                }
                else {
                    Write-Verbose "No VDIs found matching criteria"
                }
            }
            catch {
                throw "Failed to retrieve VDIs. Error: $_"
            }
        }
    }
}

function Export-XoVdi {
    <#
    .SYNOPSIS
        Export a VDI to a file.
    .DESCRIPTION
        Exports a VDI in either VHD or RAW format to a local file.
    .PARAMETER VdiId
        The ID of the VDI to export.
    .PARAMETER Format
        The format to export the VDI in (vhd or raw).
    .PARAMETER OutFile
        The path to save the exported VDI to.
    .PARAMETER PreferNbd
        Whether to prefer using NBD for the export.
    .PARAMETER NbdConcurrency
        The number of concurrent NBD connections to use.
    .EXAMPLE
        Export-XoVdi -VdiId "359e8f9c-0bef-4b3b-a13b-df62f0b578f4" -Format vhd -OutFile "./exported-vdi.vhd"
        Exports the VDI as a VHD file.
    .EXAMPLE
        Get-XoVdi -Limit 1 | Export-XoVdi -Format raw -OutFile "./exported-vdi.raw" -PreferNbd
        Exports the first VDI as a RAW file using NBD.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$VdiId,
        [Parameter(Mandatory = $true)]
        [ValidateSet('vhd', 'raw')]
        [string]$Format,
        [Parameter(Mandatory = $true)]
        [string]$OutFile
    )

    begin {
        Test-XoSession
    }

    process {
        $task = Invoke-XoApi -Method Post -Path "vdis/$VdiId/export" -Body @{
            format = $Format
        }

        $taskId = $task.id
        Write-Verbose "Export task started with ID: $taskId"

        Wait-XoTask -TaskId $taskId

        # Get the download URL
        $downloadUrl = Invoke-XoApi -Method Get -Path "vdis/$VdiId/export" | Select-Object -ExpandProperty url

        # Download the file
        Invoke-WebRequest -Uri $downloadUrl -OutFile $OutFile
        Write-Verbose "VDI exported to: $OutFile"
    }
}

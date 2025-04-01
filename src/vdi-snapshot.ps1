# SPDX-License-Identifier: Apache-2.0

$script:XO_VDI_SNAPSHOT_FIELDS = "name_label,size,uuid,snapshot_time,snapshot_of,sr_uuid"

function ConvertTo-XoVdiSnapshotObject {
    <#
    .SYNOPSIS
        Convert a VDI snapshot object from the API to a PowerShell object.
    .DESCRIPTION
        Convert a VDI snapshot object from the API to a PowerShell object with proper properties.
    .PARAMETER InputObject
        The VDI snapshot object from the API.
    #>
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process {
        $props = @{
            VdiSnapshotUuid = $InputObject.uuid
            Name = $InputObject.name_label
            SnapshotTime = if ($InputObject.snapshot_time) { [System.DateTimeOffset]::FromUnixTimeSeconds($InputObject.snapshot_time).ToLocalTime() } else { $null }
            VdiSnapshotSize = Format-XoSize $InputObject.size
            SnapshotOfVdi = $InputObject.snapshot_of
            SrUuid = $InputObject.sr_uuid
        }
        Set-XoObject $InputObject -TypeName XoPowershell.VdiSnapshot -Properties $props
    }
}

function Get-XoVdiSnapshot {
    <#
    .SYNOPSIS
        Get VDI snapshots.
    .DESCRIPTION
        Retrieves VDI snapshots from Xen Orchestra. Can retrieve specific snapshots by their ID
        or filter snapshots by various criteria.
    .PARAMETER SnapshotId
        The ID(s) of the snapshot(s) to retrieve.
    .PARAMETER Filter
        Filter to apply to the snapshot query.
    .PARAMETER Limit
        Maximum number of results to return.
    .EXAMPLE
        Get-XoVdiSnapshot -SnapshotId "a1b2c3d4"
        Returns the VDI snapshot with the specified ID.
    .EXAMPLE
        Get-XoVdiSnapshot -Filter "name_label:backup"
        Returns all VDI snapshots with "backup" in their name.
    #>
    [CmdletBinding(DefaultParameterSetName = "All")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "SnapshotId")]
        [ValidatePattern("[0-9a-z]+")]
        [Alias("VdiSnapshotUuid")]
        [string[]]$SnapshotId,

        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "All")]
        [int]$Limit
    )

    begin {
        $params = Remove-XoEmptyValues @{
            fields = $script:XO_VDI_SNAPSHOT_FIELDS
            filter = $Filter
            limit = $Limit
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "SnapshotId") {
            foreach ($id in $SnapshotId) {
                try {
                    Write-Verbose "Getting VDI snapshot with ID $id"
                    $snapshotData = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vdi-snapshots/$id" @script:XoRestParameters -Body $params
                    if ($snapshotData) {
                        ConvertTo-XoVdiSnapshotObject $snapshotData
                    } else {
                        throw "No VDI snapshot found with ID $id"
                    }
                }
                catch {
                    throw "Failed to retrieve VDI snapshot with ID $id. $_"
                }
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq "All" -or $PSCmdlet.ParameterSetName -eq "Filter") {
            try {
                Write-Verbose "Getting all VDI snapshots"
                $response = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vdi-snapshots" @script:XoRestParameters -Body $params

                if ($null -ne $response -and $response.Count -gt 0) {
                    Write-Verbose "Found $($response.Count) VDI snapshot URLs"

                    $maxToProcess = if ($Limit -gt 0) { $Limit } else { $response.Count }
                    Write-Verbose "Will process up to $maxToProcess snapshots"

                    $processedCount = 0
                    foreach ($item in $response) {
                        if ($processedCount -ge $maxToProcess) { break }

                        try {
                            $id = $null

                            if ($item -is [string]) {
                                if ($item -match '\/vdi-snapshots\/([^\/]+)(?:$|\?)') {
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
                                $snapshotData = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vdi-snapshots/$id" @script:XoRestParameters
                                if ($snapshotData) {
                                    ConvertTo-XoVdiSnapshotObject $snapshotData
                                    $processedCount++
                                }
                            } else {
                                Write-Verbose "Could not extract ID from item: $item"
                            }
                        }
                        catch {
                            throw "Failed to process VDI snapshot. $_"
                        }
                    }

                    Write-Verbose "Processed $processedCount VDI snapshots"
                } else {
                    Write-Verbose "No VDI snapshots found"
                }
            }
            catch {
                throw "Failed to retrieve VDI snapshots. $_"
            }
        }
    }
}

function Export-XoVdiSnapshot {
    <#
    .SYNOPSIS
        Export a VDI snapshot to a file.
    .DESCRIPTION
        Exports a VDI snapshot in either VHD or RAW format to a local file.
    .PARAMETER SnapshotId
        The ID of the VDI snapshot to export.
    .PARAMETER Format
        The format to export the snapshot in (vhd or raw).
    .PARAMETER OutFile
        The path to save the exported snapshot to.
    .PARAMETER PreferNbd
        Whether to prefer using NBD for the export.
    .PARAMETER NbdConcurrency
        The number of concurrent NBD connections to use.
    .EXAMPLE
        Export-XoVdiSnapshot -SnapshotId "a1b2c3d4" -Format vhd -OutFile "/path/to/export.vhd"
        Exports the VDI snapshot as a VHD file.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidatePattern("[0-9a-z]+")]
        [Alias("VdiSnapshotUuid")]
        [string]$SnapshotId,

        [Parameter(Mandatory)]
        [ValidateSet("vhd", "raw")]
        [string]$Format,

        [Parameter(Mandatory)]
        [string]$OutFile,

        [Parameter()]
        [switch]$PreferNbd,

        [Parameter()]
        [int]$NbdConcurrency
    )

    process {
        $queryParams = Remove-XoEmptyValues @{
            preferNbd = if ($PreferNbd) { "true" } else { $null }
            nbdConcurrency = $NbdConcurrency
        }

        $queryString = if ($queryParams.Count -gt 0) {
            "?" + (($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "&")
        } else { "" }

        $uri = "$script:XoHost/rest/v0/vdi-snapshots/$SnapshotId.$Format$queryString"

        Write-Verbose "Exporting VDI snapshot $SnapshotId to $OutFile in $Format format"
        Invoke-RestMethod -Uri $uri @script:XoRestParameters -OutFile $OutFile
        Write-Verbose "Export completed successfully"
    }
}

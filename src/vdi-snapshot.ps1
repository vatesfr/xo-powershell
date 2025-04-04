# SPDX-License-Identifier: Apache-2.0

$script:XO_VDI_SNAPSHOT_FIELDS = "name_label,size,uuid,snapshot_time,snapshot_of,sr_uuid,usage"

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
            Size = $InputObject.size
            Usage = $InputObject.usage
            SnapshotOfVdi = $InputObject.snapshot_of
            SrUuid = $InputObject.sr_uuid
        }
        Set-XoObject $InputObject -TypeName XoPowershell.VdiSnapshot -Properties $props
    }
}

function Get-XoSingleVdiSnapshotById {
    param (
        [string]$SnapshotId,
        [hashtable]$Params
    )
    
    try {
        Write-Verbose "Getting VDI snapshot with ID $SnapshotId"
        $snapshotData = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vdi-snapshots/$SnapshotId" @script:XoRestParameters -Body $Params
        if ($snapshotData) {
            return ConvertTo-XoVdiSnapshotObject $snapshotData
        }
    } catch {
        throw "Failed to retrieve VDI snapshot with ID $SnapshotId. $_"
    }
    return $null
}

function Get-XoVdiSnapshotIdFromItem {
    param (
        [Parameter(Mandatory)]
        $Item
    )
    
    if ($Item -is [string] -and $Item -match '\/vdi-snapshots\/([^\/]+)(?:$|\?)') {
        return $matches[1]
    }
    elseif ($Item.PSObject.Properties.Name -contains 'id') {
        return $Item.id
    }
    elseif ($Item.PSObject.Properties.Name -contains 'uuid') {
        return $Item.uuid
    }
    
    Write-Verbose "Could not extract ID from item: $Item"
    return $null
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
        [ValidatePattern("[0-9a-z\-]+")]
        [Alias("VdiSnapshotUuid", "VdiSnapshotId")]
        [string[]]$SnapshotId,

        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "All")]
        [int]$Limit = $(if ($null -ne $script:XO_DEFAULT_LIMIT) { $script:XO_DEFAULT_LIMIT } else { 25 })
    )

    if (-not $script:XoHost -or -not $script:XoRestParameters) {
        throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
    }
    
    $params = @{ fields = $script:XO_VDI_SNAPSHOT_FIELDS }
    
    if ($PSCmdlet.ParameterSetName -eq "Filter" -and $Filter) {
        $params['filter'] = $Filter
    }
    
    if ($Limit -ne 0 -and ($PSCmdlet.ParameterSetName -eq "Filter" -or $PSCmdlet.ParameterSetName -eq "All")) {
        $params['limit'] = $Limit
        if (!$PSBoundParameters.ContainsKey('Limit')) {
            Write-Warning "No limit specified. Using default limit of $Limit. Use -Limit 0 for unlimited results."
        }
    }

    if ($PSCmdlet.ParameterSetName -eq "SnapshotId") {
        foreach ($id in $SnapshotId) {
            Get-XoSingleVdiSnapshotById -SnapshotId $id -Params $params
        }
        return
    }

    try {
        Write-Verbose "Getting all VDI snapshots with parameters: $($params | ConvertTo-Json -Compress)"
        $response = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vdi-snapshots" @script:XoRestParameters -Body ($params | ConvertTo-Json -Compress) -Method Get
        
        if ($null -eq $response -or $response.Count -eq 0) {
            Write-Verbose "No VDI snapshots found"
            return
        }
        
        Write-Verbose "Found $($response.Count) VDI snapshot URLs"

        $snapshotsToProcess = $response
        if ($Limit -gt 0 -and $response.Count -gt $Limit) {
            $snapshotsToProcess = $response[0..($Limit-1)]
        }

        foreach ($item in $snapshotsToProcess) {
            $id = Get-XoVdiSnapshotIdFromItem -Item $item
            if ($id) {
                Get-XoSingleVdiSnapshotById -SnapshotId $id -Params $params
            }
        }
    }
    catch {
        throw "Failed to retrieve VDI snapshots. $_"
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
        [ValidatePattern("[0-9a-z\-]+")]
        [Alias("VdiSnapshotUuid", "VdiSnapshotId")]
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

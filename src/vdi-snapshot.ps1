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
    [CmdletBinding()]
    [OutputType("XoPowershell.VdiSnapshot")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [PSObject] $InputObject
    )

    process {
        $props = @{
            PSTypeName      = "XoPowershell.VdiSnapshot"
            VdiSnapshotUuid = $InputObject.uuid
            Name            = $InputObject.name_label
            Size            = $InputObject.size
            SnapshotOf      = $InputObject.snapshot_of
            SnapshotTime    = $InputObject.snapshot_time
            SrUuid          = $InputObject.sr_uuid
            Usage           = $InputObject.usage
        }

        [PSCustomObject]$props
    }
}

function Get-XoSingleVdiSnapshotById {
    param (
        [string]$VdiSnapshotUuid,
        [hashtable]$Params
    )

    try {
        Write-Verbose "Getting VDI snapshot with UUID $VdiSnapshotUuid"
        $uri = "$script:XoHost/rest/v0/vdi-snapshots/$VdiSnapshotUuid"
        $snapshotData = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $Params

        if ($snapshotData) {
            return ConvertTo-XoVdiSnapshotObject -InputObject $snapshotData
        }
    }
    catch {
        throw ("Failed to retrieve VDI snapshot with UUID {0}: {1}" -f $VdiSnapshotUuid, $_)
    }
    return $null
}

function Get-XoVdiSnapshot {
    <#
    .SYNOPSIS
        Get VDI snapshots from Xen Orchestra.
    .DESCRIPTION
        Retrieves VDI snapshots from Xen Orchestra. Can retrieve specific snapshots by their UUID
        or filter snapshots by various criteria.
    .PARAMETER VdiSnapshotUuid
        The UUID(s) of the VDI snapshot(s) to retrieve.
    .PARAMETER Filter
        Filter to apply to the snapshot query.
    .PARAMETER Limit
        Maximum number of results to return. Default is 25 if not specified.
    .EXAMPLE
        Get-XoVdiSnapshot
        Returns up to 25 VDI snapshots.
    .EXAMPLE
        Get-XoVdiSnapshot -Limit 0
        Returns all VDI snapshots without limit.
    .EXAMPLE
        Get-XoVdiSnapshot -VdiSnapshotUuid "12345678-abcd-1234-abcd-1234567890ab"
        Returns the VDI snapshot with the specified UUID.
    .EXAMPLE
        Get-XoVdiSnapshot -Filter "name_label:backup*"
        Returns VDI snapshots with names starting with "backup" (up to default limit).
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "VdiSnapshotUuid")]
        [Alias("VdiSnapshotId")]
        [string[]]$VdiSnapshotUuid,

        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit = $script:XoSessionLimit
    )

    begin {
        if (-not $script:XoHost -or -not $script:XoRestParameters) {
            throw ("Not connected to Xen Orchestra. Call Connect-XoSession first.")
        }

        $params = @{ fields = $script:XO_VDI_SNAPSHOT_FIELDS }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "VdiSnapshotUuid") {
            foreach ($id in $VdiSnapshotUuid) {
                Get-XoSingleVdiSnapshotById -VdiSnapshotUuid $id -Params $params
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq "Filter") {
            if ($Filter) {
                $params['filter'] = $Filter
            }

            if ($Limit) {
                $params['limit'] = $Limit
            }

            try {
                Write-Verbose "Getting VDI snapshots with parameters: $($params | ConvertTo-Json -Compress)"
                $uri = "$script:XoHost/rest/v0/vdi-snapshots"
                $response = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params

                if (!$response -or $response.Count -eq 0) {
                    Write-Verbose "No VDI snapshots found matching criteria"
                    return
                }

                Write-Verbose "Found $($response.Count) VDI snapshots"

                foreach ($snapshotItem in $response) {
                    ConvertTo-XoVdiSnapshotObject -InputObject $snapshotItem
                }
            }
            catch {
                throw ("Failed to list VDI snapshots. Error: {0}" -f $_)
            }
        }
    }
}

function Export-XoVdiSnapshot {
    <#
    .SYNOPSIS
        Export a VDI snapshot.
    .DESCRIPTION
        Export a VDI snapshot from Xen Orchestra. Downloads the snapshot to a local file.
    .PARAMETER VdiSnapshotUuid
        The UUID of the VDI snapshot to export.
    .PARAMETER Format
        The format to export the VDI snapshot in. Valid values: raw, vhd.
    .PARAMETER OutFile
        The path to save the exported VDI snapshot to.
    .PARAMETER PassThru
        If specified, returns the exported file info as a FileInfo object.
    .EXAMPLE
        Export-XoVdiSnapshot -VdiSnapshotUuid "12345678-abcd-1234-abcd-1234567890ab" -Format vhd -OutFile "C:\Exports\snapshot.vhd"
        Exports the VDI snapshot in VHD format to the specified file.
    .EXAMPLE
        Get-XoVdiSnapshot -VdiSnapshotUuid "12345678-abcd-1234-abcd-1234567890ab" | Export-XoVdiSnapshot -Format vhd -OutFile "C:\Exports\snapshot.vhd"
        Exports the VDI snapshot in VHD format to the specified file, piping from Get-XoVdiSnapshot.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias("VdiSnapshotId")]
        [string]$VdiSnapshotUuid,

        [Parameter(Mandatory)]
        [ValidateSet("raw", "vhd")]
        [string]$Format,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OutFile,

        [Parameter()]
        [switch]$PassThru
    )


    process {
        $resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutFile)

        if ($PSCmdlet.ShouldProcess($VdiSnapshotUuid, "export to $resolvedPath in $Format format")) {
            try {
                $uri = "$script:XoHost/rest/v0/vdi-snapshots/$VdiSnapshotUuid/export"
                $params = @{ format = $Format }

                Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params -OutFile $resolvedPath

                if ($PassThru) {
                    Get-Item $resolvedPath
                }
            }
            catch {
                throw ("Failed to export VDI snapshot with UUID {0}: {1}" -f $VdiSnapshotUuid, $_)
            }
        }
    }
}

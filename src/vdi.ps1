# SPDX-License-Identifier: Apache-2.0

$script:XO_VDI_FIELDS = "name_label,uuid,content_type,size,usage,physical_usage,$SR,sr_uuid,sr_usage"

function ConvertTo-XoVdiObject {
    <#
    .SYNOPSIS
        Convert a VDI object from the API to a PowerShell object.
    .DESCRIPTION
        Convert a VDI object from the API to a PowerShell object with proper properties and types.
    .PARAMETER InputObject
        The VDI object from the API.
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Vdi")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [PSObject] $InputObject
    )


    process {
        $props = @{
            PSTypeName = "XoPowershell.Vdi"
            VdiUuid = $InputObject.uuid
            Name = $InputObject.name_label
            ContentType = $InputObject.content_type
            Size = $InputObject.size
            Usage = $InputObject.usage
            PhysicalUsage = $InputObject.physical_usage
            SrUuid = $InputObject.sr_uuid
            SrUsage = $InputObject.sr_usage
        }

        [PSCustomObject]$props
    }
}

function Get-XoVdiIdFromItem {
    param(
        [Parameter(Mandatory)]
        $VdiItem
    )
    
    if ($VdiItem -match "/vdis/([^/]+)") {
        return $matches[1]
    }
    
    if ($VdiItem.PSObject.Properties.Name -contains 'uuid') {
        return $VdiItem.uuid
    }
    
    return $null
}

function Get-XoSingleVdiById {
    param (
        [string]$VdiUuid,
        [hashtable]$Params
    )
    
    try {
        Write-Verbose "Getting VDI with UUID $VdiUuid"
        $uri = "$script:XoHost/rest/v0/vdis/$VdiUuid"
        $vdiData = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $Params
        
        if ($vdiData) {
            return ConvertTo-XoVdiObject -InputObject $vdiData
        }
    } catch {
        throw ("Failed to retrieve VDI with UUID {0}: {1}" -f $VdiUuid, $_)
    }
    return $null
}

function Get-XoVdi {
    <#
    .SYNOPSIS
        Get VDIs from Xen Orchestra.
    .DESCRIPTION
        Retrieves VDIs from Xen Orchestra. Can retrieve specific VDIs by their UUID
        or filter VDIs by various criteria.
    .PARAMETER VdiUuid
        The UUID(s) of the VDI(s) to retrieve.
    .PARAMETER SrUuid
        Filter VDIs by storage repository UUID.
    .PARAMETER Filter
        Custom filter to apply to the VDI query.
    .PARAMETER Limit
        Maximum number of results to return. Default is 25 if not specified.
    .EXAMPLE
        Get-XoVdi
        Returns up to 25 VDIs.
    .EXAMPLE
        Get-XoVdi -Limit 0
        Returns all VDIs without limit.
    .EXAMPLE
        Get-XoVdi -VdiUuid "12345678-abcd-1234-abcd-1234567890ab"
        Returns the VDI with the specified UUID.
    .EXAMPLE
        Get-XoVdi -SrUuid "12345678-abcd-1234-abcd-1234567890ab"
        Returns VDIs on the specified storage repository (up to default limit).
    .EXAMPLE
        Get-XoVdi -Filter "name_label:backup*"
        Returns VDIs with names starting with "backup" (up to default limit).
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "VdiUuid")]
        [Alias("VdiId")]
        [string[]]$VdiUuid,
        
        [Parameter(ParameterSetName = "Filter")]
        [string]$SrUuid,

        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,
        
        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit = $script:XoSessionLimit
    )

    begin {
        if (-not $script:XoHost -or -not $script:XoRestParameters) {
            throw ("Not connected to Xen Orchestra. Call Connect-XoSession first.")
        }
        
        $params = @{ fields = $script:XO_VDI_FIELDS }
        
        $filterParts = @()
        
        if ($SrUuid) {
            $filterParts += "sr_uuid:$SrUuid"
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
        if ($PSCmdlet.ParameterSetName -eq "VdiUuid") {
            foreach ($id in $VdiUuid) {
                Get-XoSingleVdiById -VdiUuid $id -Params $params
            }
        }
    }
    
    end {
        if ($PSCmdlet.ParameterSetName -eq "Filter") {
            try {
                Write-Verbose "Getting VDIs with parameters: $($params | ConvertTo-Json -Compress)"
                $uri = "$script:XoHost/rest/v0/vdis"
                $response = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params
                
                if (!$response -or $response.Count -eq 0) {
                    Write-Verbose "No VDIs found matching criteria"
                    return
                }
                
                Write-Verbose "Found $($response.Count) VDIs"
                
                foreach ($vdiItem in $response) {
                    ConvertTo-XoVdiObject -InputObject $vdiItem
                }
            } catch {
                throw ("Failed to list VDIs. Error: {0}" -f $_)
            }
        }
    }
}

function Export-XoVdi {
    <#
    .SYNOPSIS
        Export a VDI.
    .DESCRIPTION
        Export a VDI from Xen Orchestra. Downloads the VDI to a local file.
    .PARAMETER VdiUuid
        The UUID of the VDI to export.
    .PARAMETER Format
        The format to export the VDI in. Valid values: raw, vhd.
    .PARAMETER OutFile
        The path to save the exported VDI to.
    .PARAMETER PassThru
        If specified, returns the exported file info as a FileInfo object.
    .EXAMPLE
        Export-XoVdi -VdiUuid "12345678-abcd-1234-abcd-1234567890ab" -Format vhd -OutFile "C:\Exports\disk.vhd"
        Exports the VDI in VHD format to the specified file.
    .EXAMPLE
        Get-XoVdi -VdiUuid "12345678-abcd-1234-abcd-1234567890ab" | Export-XoVdi -Format vhd -OutFile "C:\Exports\disk.vhd"
        Exports the VDI in VHD format to the specified file, piping from Get-XoVdi.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias("VdiId")]
        [string]$VdiUuid,
        
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
        
        if ($PSCmdlet.ShouldProcess($VdiUuid, "export to $resolvedPath in $Format format")) {
            try {
                $uri = "$script:XoHost/rest/v0/vdis/$VdiUuid/export"
                $params = @{ format = $Format }
                
                Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params -OutFile $resolvedPath
                
                if ($PassThru) {
                    Get-Item $resolvedPath
                }
            } catch {
                throw ("Failed to export VDI with UUID {0}: {1}" -f $VdiUuid, $_)
            }
        }
    }
}

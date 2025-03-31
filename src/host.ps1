$script:XO_HOST_FIELDS = "uuid,name_label,power_state,memory,address,hostname,version,productBrand"

function ConvertTo-XoHostObject {
    <#
    .SYNOPSIS
        Convert a host object from the API to a PowerShell object.
    .DESCRIPTION
        Convert a host object from the API to a PowerShell object with proper properties and types.
    .PARAMETER InputObject
        The host object from the API.
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Host")]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )
    
    process {
        $resultObject = [PSCustomObject]@{
            PSTypeName = "XoPowershell.Host"
            HostUuid = $InputObject.id
            Description = $InputObject.name_description
            Label = $InputObject.name_label
            MemoryFree = [int64]$InputObject.memory.free
            MemoryTotal = [int64]$InputObject.memory.total
            Cpus = $InputObject.cpus.cores
            Power = $InputObject.power_state
            StartTime = $InputObject.startTime
            Tags = $InputObject.tags
            Address = $InputObject.address
            Bios = $InputObject.bios_strings.bios_vendor
            CPUModel = $InputObject.cpu_info.modelname
            Build = $InputObject.software_version.build_number
            Version = $InputObject.software_version.product_version
            ProductBrand = $InputObject.software_version.product_brand
        }
        
        return $resultObject
    }
}

function Get-XoHost {
    <#
    .SYNOPSIS
        Get physical hosts from Xen Orchestra.
    .DESCRIPTION
        Retrieves physical XCP-ng/XenServer hosts from Xen Orchestra. 
        Can retrieve specific hosts by their UUID or filter hosts by various criteria.
    .PARAMETER HostId
        The UUID(s) of the host(s) to retrieve.
    .PARAMETER Filter
        Filter to apply to the host query.
    .PARAMETER Limit
        Maximum number of results to return.
    .EXAMPLE
        Get-XoHost
        Returns all hosts.
    .EXAMPLE
        Get-XoHost -HostId "12345678-abcd-1234-abcd-1234567890ab"
        Returns the host with the specified UUID.
    .EXAMPLE
        Get-XoHost -Filter "power_state:running"
        Returns all running hosts.
    #>
    [CmdletBinding(DefaultParameterSetName = "All")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "HostId")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [Alias("HostUuid")]
        [string[]]$HostId,
        
        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,
        
        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "All")]
        [int]$Limit
    )

    begin {
        Write-Verbose "Getting XO hosts"
        $params = @{}
        if ($PSBoundParameters.ContainsKey('Filter')) {
            $params['filter'] = $Filter
        }
        if ($PSBoundParameters.ContainsKey('Limit')) {
            $params['limit'] = $Limit
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "HostId") {
            foreach ($id in $HostId) {
                try {
                    Write-Verbose "Getting host with ID $id"
                    $hostData = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/hosts/$id" @script:XoRestParameters
                    if ($hostData) {
                        ConvertTo-XoHostObject $hostData
                    }
                } catch {
                    Write-Error "Failed to retrieve host with ID $id. Error: $_"
                }
            }
        }
    }
    
    end {
        if ($PSCmdlet.ParameterSetName -eq "All" -or $PSCmdlet.ParameterSetName -eq "Filter") {
            try {
                Write-Verbose "Getting all hosts" 
                $hostUrls = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/hosts" @script:XoRestParameters
                
                if ($hostUrls -and $hostUrls.Count -gt 0) {
                    Write-Verbose "Found $($hostUrls.Count) hosts"
                    
                    # Apply limit if specified
                    $processLimit = if ($Limit -gt 0) { [Math]::Min($Limit, $hostUrls.Count) } else { $hostUrls.Count }
                    $processUrls = $hostUrls | Select-Object -First $processLimit
                    
                    foreach ($hostUrl in $processUrls) {
                        # Skip null or empty URLs
                        if ([string]::IsNullOrEmpty($hostUrl)) {
                            continue
                        }
                        
                        try {
                            # Extract the ID from the URL string
                            $match = [regex]::Match($hostUrl, "\/rest\/v0\/hosts\/([^\/]+)$")
                            if ($match.Success) {
                                $id = $match.Groups[1].Value
                                if (![string]::IsNullOrEmpty($id)) {
                                    $hostDetail = Invoke-RestMethod -Uri "$script:XoHost$hostUrl" @script:XoRestParameters

                                    if ($hostDetail) {
                                        # Parse the response if it's a string
                                        if ($hostDetail -is [string]) {
                                            $hostDetail = $hostDetail | ConvertFrom-Json -AsHashtable
                                        }
                                        
                                        ConvertTo-XoHostObject $hostDetail
                                    }
                                }
                                else {
                                    Write-Warning "Failed to extract valid ID from URL: $hostUrl"
                                }
                            }
                        } catch {
                            Write-Warning "Failed to retrieve host details from URL: $hostUrl. Error: $_"
                        }
                    }
                }
                else {
                    Write-Verbose "No hosts found"
                }
            }
            catch {
                Write-Error "Failed to list hosts. Error: $_"
            }
        }
    }
} 
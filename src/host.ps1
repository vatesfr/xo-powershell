# SPDX-License-Identifier: Apache-2.0

$script:XO_HOST_FIELDS = "id,uuid,name_label,name_description,power_state,memory,address,hostname,version,productBrand,build,cpus,startTime,tags,bios_strings,software_version,cpu_info,CPUs"

function ConvertTo-XoHostObject {
    <#
    .SYNOPSIS
        Convert a host object from the API to a PowerShell object.
    .DESCRIPTION
        Convert a host object from the API to a PowerShell object with proper properties and types.
    .PARAMETER HostData
        The host object from the API.
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Host")]
    param (
        [Parameter(Mandatory, Position = 0)]
        $HostData
    )
    
    if ($HostData -is [string]) {
        try {
            Write-Verbose "HostData is a string, attempting to convert from JSON"
            $HostData = $HostData | ConvertFrom-Json -AsHashtable
        } catch {
            Write-Error "Failed to convert host data from JSON string: $_"
            return $null
        }
    }
    
    Write-Verbose "Processing host data: name_label=$($HostData.name_label), id=$($HostData.id), uuid=$($HostData.uuid), address=$($HostData.address)"

    $hostObj = [PSCustomObject]@{
        PSTypeName  = "XoHost"
        HostUuid    = $HostData.id ?? $HostData.uuid ?? ""
        Name        = $HostData.name_label ?? "Unknown"
        Address     = $HostData.address ?? "Unknown"
        PowerState  = $HostData.power_state ?? "Unknown"
        MemoryFree  = 0
        MemoryTotal = 0
        Cpus        = 0
        Description = $HostData.name_description
        StartTime   = $HostData.startTime
        Tags        = $HostData.tags
        Version     = $HostData.version
        ProductBrand = $HostData.productBrand
    }

    if ($HostData.ContainsKey('cpus') -and $HostData['cpus'] -and $HostData['cpus'].ContainsKey('cores')) {
        $hostObj.Cpus = $HostData['cpus']['cores']
    } elseif ($HostData.ContainsKey('CPUs') -and $HostData['CPUs'] -and $HostData['CPUs'].ContainsKey('cpu_count')) {
        $hostObj.Cpus = [int]$HostData['CPUs']['cpu_count']
    }

    if ($HostData.ContainsKey('memory') -and $HostData['memory']) {
        $memory = $HostData['memory']
        if ($memory.ContainsKey('size')) {
            $hostObj.MemoryTotal = [math]::Round($memory['size'] / 1GB, 2)
        }
        if ($memory.ContainsKey('usage')) {
            $memoryFree = $memory['size'] - $memory['usage']
            $hostObj.MemoryFree = [math]::Round($memoryFree / 1GB, 2)
        }
    }

    if ($hostObj.PowerState -and $hostObj.PowerState -ne "Unknown") {
        $hostObj.PowerState = $hostObj.PowerState.Replace("_", " ")
        $hostObj.PowerState = (Get-Culture).TextInfo.ToTitleCase($hostObj.PowerState.ToLower())
    }

    Write-Verbose "Created host object: Name=$($hostObj.Name), UUID=$($hostObj.HostUuid), Address=$($hostObj.Address), PowerState=$($hostObj.PowerState), MemoryTotal=$($hostObj.MemoryTotal), MemoryFree=$($hostObj.MemoryFree), Cpus=$($hostObj.Cpus)"
    return $hostObj
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
        Maximum number of results to return. Default is 25 if not specified.
    .EXAMPLE
        Get-XoHost
        Returns up to 25 hosts.
    .EXAMPLE
        Get-XoHost -Limit 0
        Returns all hosts without limit.
    .EXAMPLE
        Get-XoHost -HostId "12345678-abcd-1234-abcd-1234567890ab"
        Returns the host with the specified UUID.
    .EXAMPLE
        Get-XoHost -Filter "power_state:running"
        Returns running hosts (up to default limit).
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
        [int]$Limit = 25
    )

    if (-not $script:XoHost -or -not $script:XoRestParameters) {
        throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
    }

    if ($PSCmdlet.ParameterSetName -eq "HostId") {
        foreach ($id in $HostId) {
            try {
                $uri = "$script:XoHost/rest/v0/hosts/$id"
                Write-Verbose "Getting host with ID $id from $uri"
                
                $hostData = Invoke-RestMethod -Uri $uri @script:XoRestParameters
                
                if ($hostData) {
                    $hostObj = ConvertTo-XoHostObject -HostData $hostData
                    if ($hostObj) {
                        Write-Output $hostObj
                    }
                } else {
                    Write-Warning "No host data received for ID $id"
                }
            } catch {
                Write-Error "Failed to retrieve host with ID $id. Error: $_"
            }
        }
        return
    }
    
    try {
        $uri = "$script:XoHost/rest/v0/hosts"
        Write-Verbose "Getting list of all hosts from $uri"
        
        $allHostsResponse = Invoke-RestMethod -Uri $uri @script:XoRestParameters
        Write-Verbose "API response received with $($allHostsResponse.Count) total hosts"

        $hostsToProcess = $allHostsResponse
        if ($Limit -gt 0 -and $allHostsResponse.Count -gt $Limit) {
            $hostsToProcess = $allHostsResponse[0..($Limit-1)]
            Write-Verbose "Processing first $Limit hosts out of $($allHostsResponse.Count) total"
        } else {
            Write-Verbose "Processing all $($allHostsResponse.Count) hosts"
        }
        
        $processedCount = 0
        
        foreach ($hostUrl in $hostsToProcess) {
            $cleanUrl = $hostUrl.Trim('",\[\] \n\r\t')
            if ([string]::IsNullOrEmpty($cleanUrl)) {
                continue
            }

            if ($cleanUrl -match "/hosts/([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})") {
                $hostId = $matches[1]
                try {
                    Write-Verbose "Fetching host details for ID $hostId ($($processedCount+1) of $($hostsToProcess.Count))"
                    $hostDetail = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/hosts/$hostId" @script:XoRestParameters
                    
                    if ($hostDetail) {
                        $hostObj = ConvertTo-XoHostObject -HostData $hostDetail
                        if ($hostObj) {
                            $processedCount++
                            Write-Output $hostObj
                        }
                    } else {
                        Write-Warning "No host details received for ID $hostId"
                    }
                } catch {
                    Write-Error "Failed to get details for host $hostId : $_"
                }
            } else {
                Write-Warning "Could not extract host ID from URL: $cleanUrl"
            }
        }
        
        if ($processedCount -eq 0) {
            Write-Verbose "No hosts found"
        } else {
            Write-Verbose "Successfully processed $processedCount hosts"
        }
    }
    catch {
        Write-Error "Failed to list hosts. Error: $_"
    }
}
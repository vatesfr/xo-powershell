# SPDX-License-Identifier: Apache-2.0

$script:XO_HOST_FIELDS = "uuid,name_label,name_description,power_state,memory,address,hostname,version,productBrand,build,startTime,tags,bios_strings,license_params,license_server,license_expiry,residentVms,PIFs,PCIs,PGPUs,poolId,CPUs"

function ConvertTo-XoHostObject {
    <#
    .SYNOPSIS
        Convert a host object from the API to a PowerShell object.
    .DESCRIPTION
        Convert a host object from the API to a PowerShell object with proper properties and types.
        This function creates a flat object using the raw values from the API response.
    .PARAMETER InputObject
        The host object from the API.
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Host")]
    param (
        [Parameter(Mandatory, Position = 0)]
        $InputObject
    )

    $hostObj = [PSCustomObject]@{
        PSTypeName    = "XoPowershell.Host"
        HostUuid      = $InputObject.uuid
        Name          = $InputObject.name_label
        Address       = $InputObject.address
        PowerState    = $InputObject.power_state
        Description   = $InputObject.name_description
        StartTime     = $InputObject.startTime
        Tags          = $InputObject.tags
        Version       = $InputObject.version
        ProductBrand  = $InputObject.productBrand
        BiosStrings   = $InputObject.bios_strings
        Build         = $InputObject.build
        Hostname      = $InputObject.hostname
        LicenseParams = $InputObject.license_params
        LicenseServer = $InputObject.license_server
        LicenseExpiry = $InputObject.license_expiry
        ResidentVms   = $InputObject.residentVms
        Pifs          = $InputObject.PIFs
        PcIs          = $InputObject.PCIs
        PGpus         = $InputObject.PGPUs
        PoolId        = $InputObject.poolId
        Memory        = $InputObject.memory
        CPUs          = $InputObject.CPUs
    }

    if ($InputObject.CPUs -and $InputObject.CPUs.cpu_count) {
        $hostObj | Add-Member -NotePropertyName "VCpus" -NotePropertyValue $InputObject.CPUs.cpu_count
    } elseif ($InputObject.cpus -and $InputObject.cpus.cores) {
        $hostObj | Add-Member -NotePropertyName "VCpus" -NotePropertyValue $InputObject.cpus.cores
    }
    
    return $hostObj
}

function Get-XoSingleHostById {
    param (
        [string]$HostId,
        [hashtable]$Params
    )
    
    try {
        $uri = "$script:XoHost/rest/v0/hosts/$HostId"
        $hostData = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body ($Params | ConvertTo-Json -Compress) -Method Get
        
        $hostData = $hostData | ConvertFrom-Json -AsHashTable
        
        if ($hostData) {
            return ConvertTo-XoHostObject -InputObject $hostData
        }
    } catch {
        throw "Failed to retrieve host with ID $HostId. Error: $_"
    }
    return $null
}

function Get-XoHostDetailFromPath {
    param(
        [string]$HostDetail
    )
    
    if ($HostDetail -match "/hosts/([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})") {
        $hostId = $matches[1]
        $hostDetailUri = "$script:XoHost/rest/v0/hosts/$hostId"
        $detailParams = @{ fields = $script:XO_HOST_FIELDS }
        
        try {
            $response = Invoke-RestMethod -Uri $hostDetailUri @script:XoRestParameters -Body ($detailParams | ConvertTo-Json -Compress) -Method Get
            return $response | ConvertFrom-Json -AsHashTable
        } catch {
            Write-Warning "Error fetching host detail for ID $hostId. Error: $_"
            return $null
        }
    }
    return $HostDetail
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
        [int]$Limit = $(if ($null -ne $script:XO_DEFAULT_LIMIT) { $script:XO_DEFAULT_LIMIT } else { 25 })
    )

    if (-not $script:XoHost -or -not $script:XoRestParameters) {
        throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
    }

    $params = @{ fields = $script:XO_HOST_FIELDS }

    if ($PSCmdlet.ParameterSetName -eq "Filter" -and $Filter) {
        $params['filter'] = $Filter
    }

    if ($Limit -ne 0 -and ($PSCmdlet.ParameterSetName -eq "Filter" -or $PSCmdlet.ParameterSetName -eq "All")) {
        $params['limit'] = $Limit
        if (!$PSBoundParameters.ContainsKey('Limit')) {
            Write-Warning "No limit specified. Using default limit of $Limit. Use -Limit 0 for unlimited results."
        }
    }

    if ($PSCmdlet.ParameterSetName -eq "HostId") {
        foreach ($id in $HostId) {
            Get-XoSingleHostById -HostId $id -Params $params
        }
        return
    }

    try {
        $uri = "$script:XoHost/rest/v0/hosts"
        $hostsResponse = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body ($params | ConvertTo-Json -Compress) -Method Get
        
        if (!$hostsResponse -or $hostsResponse.Count -eq 0) {
            Write-Verbose "No hosts found"
            return
        }

        $hostsToProcess = $hostsResponse
        if ($Limit -gt 0 -and $hostsResponse.Count -gt $Limit) {
            $hostsToProcess = $hostsResponse[0..($Limit-1)]
        }

        foreach ($hostDetail in $hostsToProcess) {
            $fullHostDetail = Get-XoHostDetailFromPath -HostDetail $hostDetail
            if ($fullHostDetail) {
                $hostObj = ConvertTo-XoHostObject -InputObject $fullHostDetail
                Write-Output $hostObj
            }
        }
    } catch {
        $errorMsg = "Failed to list hosts. Error: $($_.Exception.Message)"
        if ($_.Exception.Response) {
            $errorMsg += " Response: $($_.Exception.Response.Content | Out-String)"
        }
        throw $errorMsg
    }
}
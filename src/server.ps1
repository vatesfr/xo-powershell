# SPDX-License-Identifier: Apache-2.0

$script:XO_SERVER_FIELDS = "id,label,host,status,enabled,username,allowUnauthorized,readOnly,poolId,poolNameLabel,version"

function ConvertTo-XoServerObject {
    <#
    .SYNOPSIS
        Convert a server object from the API to a PowerShell object.
    .DESCRIPTION
        Convert a server object from the API to a PowerShell object with proper properties and types.
    .PARAMETER InputObject
        The server object from the API.
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Server")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        $InputObject
    )

    process {
        $props = @{
            PSTypeName = "XoPowershell.Server"
            ServerUuid = $InputObject.id
            Name = $InputObject.label
            Address = $InputObject.host
            Status = $InputObject.status
            Enabled = $InputObject.enabled
            Username = $InputObject.username
            AllowUnauthorized = $InputObject.allowUnauthorized
            ReadOnly = $InputObject.readOnly
            PoolId = $InputObject.poolId
            PoolName = $InputObject.poolNameLabel
            Version = $InputObject.version
        }
        
        [PSCustomObject]$props
    }
}

function Get-XoSingleServerById {
    param (
        [string]$ServerId,
        [hashtable]$Params
    )
    
    try {
        $uri = "$script:XoHost/rest/v0/servers/$ServerId"
        Write-Verbose "Getting server with ID $ServerId from $uri"
        
        $serverData = Invoke-RestMethod -Uri $uri @script:XoRestParameters
        if ($serverData -is [string]) {
            $serverData = $serverData | ConvertFrom-Json -AsHashTable
        }
        
        if ($serverData) {
            return ConvertTo-XoServerObject -InputObject $serverData
        }
    } catch {
        $errorMessage = $_
        throw "Failed to retrieve server with ID $ServerId. Error: $errorMessage"
    }
    return $null
}

function Get-XoServerDetailFromUrl {
    param(
        [string]$ServerUrl
    )
    
    if ([string]::IsNullOrEmpty($ServerUrl)) {
        return $null
    }
    
    $match = [regex]::Match($ServerUrl, "\/rest\/v0\/servers\/([^\/]+)$")
    if (!$match.Success) {
        Write-Warning "URL doesn't match expected pattern: $ServerUrl"
        return $null
    }
    
    $id = $match.Groups[1].Value
    if ([string]::IsNullOrEmpty($id)) {
        Write-Warning "Failed to extract valid ID from URL: $ServerUrl"
        return $null
    }
    
    try {
        $serverDetail = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/servers/$id" @script:XoRestParameters
        if ($serverDetail -is [string]) {
            $serverDetail = $serverDetail | ConvertFrom-Json -AsHashTable
        }
        return $serverDetail
    } catch {
        $errorMessage = $_
        Write-Warning "Error fetching server detail for ID $id`: $errorMessage"
        return $null
    }
}

function Get-XoServer {
    <#
    .SYNOPSIS
        Get servers from Xen Orchestra.
    .DESCRIPTION
        Retrieves servers from Xen Orchestra. Can retrieve specific servers by their UUID
        or filter servers by various criteria.
    .PARAMETER ServerUuid
        The UUID(s) of the server(s) to retrieve.
    .PARAMETER Filter
        Filter to apply to the server query.
    .PARAMETER Limit
        Maximum number of results to return. Default is 25 if not specified.
    .EXAMPLE
        Get-XoServer
        Returns up to 25 servers.
    .EXAMPLE
        Get-XoServer -Limit 0
        Returns all servers without limit.
    .EXAMPLE
        Get-XoServer -ServerUuid "12345678-abcd-1234-abcd-1234567890ab"
        Returns the server with the specified UUID.
    .EXAMPLE
        Get-XoServer -Filter "status:connected"
        Returns connected servers (up to default limit).
    #>
    [CmdletBinding(DefaultParameterSetName = "All")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "ServerUuid")]
        [string[]]$ServerUuid,

        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "All")]
        [int]$Limit = $(if ($null -ne $script:XO_DEFAULT_LIMIT) { $script:XO_DEFAULT_LIMIT } else { 25 })
    )

    if (-not $script:XoHost -or -not $script:XoRestParameters) {
        throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
    }
    
    $params = @{}
    if ($PSBoundParameters.ContainsKey('Filter')) {
        $params['filter'] = $Filter
    }
    
    if ($Limit -ne 0 -and ($PSCmdlet.ParameterSetName -eq "Filter" -or $PSCmdlet.ParameterSetName -eq "All")) {
        $params['limit'] = $Limit
        if (!$PSBoundParameters.ContainsKey('Limit')) {
            Write-Warning "No limit specified. Using default limit of $Limit. Use -Limit 0 for unlimited results."
        }
    }
    
    if ($PSCmdlet.ParameterSetName -eq "ServerUuid") {
        foreach ($id in $ServerUuid) {
            Get-XoSingleServerById -ServerId $id -Params $params
        }
        return
    }
    
    try {
        $uri = "$script:XoHost/rest/v0/servers"
        Write-Verbose "Getting servers from $uri with parameters: $($params | ConvertTo-Json -Compress)"
        
        $serversResponse = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body ($params | ConvertTo-Json -Compress) -Method Get
        
        if (!$serversResponse -or $serversResponse.Count -eq 0) {
            Write-Verbose "No servers found"
            return
        }
        
        $serversToProcess = $serversResponse
        if ($Limit -gt 0 -and $serversResponse.Count -gt $Limit) {
            $serversToProcess = $serversResponse[0..($Limit-1)]
        }
        
        foreach ($serverUrl in $serversToProcess) {
            $serverDetail = Get-XoServerDetailFromUrl -ServerUrl $serverUrl
            if ($serverDetail) {
                $serverObj = ConvertTo-XoServerObject -InputObject $serverDetail
                Write-Output $serverObj
            }
        }
    } catch {
        $errorMessage = $_.Exception.Message
        $errorMsg = "Failed to list servers. Error: $errorMessage"
        if ($_.Exception.Response) {
            $responseContent = $_.Exception.Response.Content | Out-String
            $errorMsg += " Response: $responseContent"
        }
        throw $errorMsg
    }
}
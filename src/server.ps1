# SPDX-License-Identifier: Apache-2.0

$script:XO_SERVER_FIELDS = "id,host,label,address,version,status,enabled,error,username,readOnly,allowUnauthorized"

function ConvertTo-XoServerObject {
    <#
    .SYNOPSIS
        Convert a server object from the API to a PowerShell object.
    .DESCRIPTION
        Convert a server object from the API to a PowerShell object with proper properties.
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
            ServerUuid = $InputObject.id
            Name       = $InputObject.label
            NameHost   = $InputObject.host
            Address    = $InputObject.address
            Status     = $InputObject.status
            Version    = $InputObject.version
            Enabled    = $InputObject.enabled
            ReadOnly   = $InputObject.readOnly
            Username   = $InputObject.username
            Error      = $InputObject.error
            AllowUnauthorized = $InputObject.allowUnauthorized
        }
        
        Set-XoObject $InputObject -TypeName XoPowershell.Server -Properties $props
    }
}

function Get-XoSingleServerById {
    param (
        [string]$ServerUuid,
        [hashtable]$Params
    )
    
    try {
        Write-Verbose "Getting server with ID $ServerUuid"
        $uri = "$script:XoHost/rest/v0/servers/$ServerUuid"

        if ($null -eq $Params) {
            $Params = @{}
        }
        if (-not $Params.ContainsKey('fields')) {
            $Params['fields'] = $script:XO_SERVER_FIELDS
        }
        
        $serverData = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $Params
        
        if ($serverData) {
            return ConvertTo-XoServerObject -InputObject $serverData
        }
    } catch {
        throw ("Failed to retrieve server with ID {0}: {1}" -f $ServerUuid, $_)
    }
    return $null
}

function Get-XoServerDetailFromUrl {
    param(
        [string]$ServerPath
    )
    
    if ([string]::IsNullOrEmpty($ServerPath)) {
        return $null
    }
    
    if ($ServerPath -match "/servers/([^/]+)") {
        $serverId = $matches[1]
        $serverDetailUri = "$script:XoHost/rest/v0/servers/$serverId"
        
        try {
            Write-Verbose "Fetching server details for ID $serverId from URL"
            $serverDetail = Invoke-RestMethod -Uri $serverDetailUri @script:XoRestParameters
            return ConvertTo-XoServerObject -InputObject $serverDetail
        } catch {
            throw ("Error fetching server detail for ID {0}: {1}" -f $serverId, $_)
        }
    }
    return $ServerPath
}

function Get-XoServer {
    <#
    .SYNOPSIS
        Get servers from Xen Orchestra.
    .DESCRIPTION
        Retrieves servers from Xen Orchestra. Can retrieve specific servers by their ID
        or filter servers by various criteria.
    .PARAMETER ServerUuid
        The ID(s) of the server(s) to retrieve.
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
        Returns the server with the specified ID.
    .EXAMPLE
        Get-XoServer -Filter "status:connected"
        Returns connected servers (up to default limit).
    #>
    [CmdletBinding(DefaultParameterSetName = "All")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "ServerUuid")]
        [Alias("ServerId")]
        [string[]]$ServerUuid,

        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "All")]
        [int]$Limit = $script:XoSessionLimit
    )

    begin {
        if (-not $script:XoHost -or -not $script:XoRestParameters) {
            throw ("Not connected to Xen Orchestra. Call Connect-XoSession first.")
        }
        
        $params = @{ fields = $script:XO_SERVER_FIELDS }
        
        if ($PSCmdlet.ParameterSetName -eq "Filter" -and $Filter) {
            $params['filter'] = $Filter
        }
        
        if ($Limit -ne 0 -and ($PSCmdlet.ParameterSetName -eq "Filter" -or $PSCmdlet.ParameterSetName -eq "All")) {
            $params['limit'] = $Limit
            if (!$PSBoundParameters.ContainsKey('Limit')) {
                Write-Warning "No limit specified. Using default limit of $Limit. Use -Limit 0 for unlimited results."
            }
        }
    }
    
    process {
        if ($PSCmdlet.ParameterSetName -eq "ServerUuid") {
            foreach ($id in $ServerUuid) {
                Get-XoSingleServerById -ServerUuid $id -Params $params
            }
        }
    }
    
    end {
        if ($PSCmdlet.ParameterSetName -eq "All" -or $PSCmdlet.ParameterSetName -eq "Filter") {
            try {
                Write-Verbose "Getting servers with parameters: $($params | ConvertTo-Json -Compress)"
                $uri = "$script:XoHost/rest/v0/servers"
                $response = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params
                
                if (!$response -or $response.Count -eq 0) {
                    Write-Verbose "No servers found matching criteria"
                    return
                }
                
                Write-Verbose "Found $($response.Count) servers"
                
                $serversToProcess = $response
                if ($Limit -gt 0 -and $response.Count -gt $Limit) {
                    $serversToProcess = $response[0..($Limit-1)]
                }
                
                foreach ($serverItem in $serversToProcess) {
                    ConvertTo-XoServerObject -InputObject $serverItem
                }
            } catch {
                throw ("Failed to list servers. Error: {0}" -f $_)
            }
        }
    }
}
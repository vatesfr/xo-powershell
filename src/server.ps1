$script:XO_SERVER_FIELDS = "id,label,host,status,enabled,username,allowUnauthorized,readOnly,poolId,poolNameLabel,version"

function ConvertTo-XoServerObject {
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process {
        $props = @{
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
        Set-XoObject $InputObject -TypeName XoPowershell.Server -Properties $props
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
        Maximum number of results to return.
    .EXAMPLE
        Get-XoServer
        Returns all servers.
    .EXAMPLE
        Get-XoServer -ServerUuid "12345678-abcd-1234-abcd-1234567890ab"
        Returns the server with the specified UUID.
    .EXAMPLE
        Get-XoServer -Filter "power_state:running"
        Returns all running servers.
    #>
    [CmdletBinding(DefaultParameterSetName = "All")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "ServerUuid")]
        [string[]]$ServerUuid,
        
        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,
        
        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "All")]
        [int]$Limit
    )

    begin {
        $params = @{}
        if ($PSBoundParameters.ContainsKey('Filter')) {
            $params['filter'] = $Filter
        }
        if ($PSBoundParameters.ContainsKey('Limit')) {
            $params['limit'] = $Limit
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "ServerUuid") {
            foreach ($id in $ServerUuid) {
                try {
                    Write-Verbose "Getting server with ID $id"
                    $serverData = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/servers/$id" @script:XoRestParameters
                    if ($serverData) {
                        ConvertTo-XoServerObject $serverData
                    }
                }
                catch {
                    Write-Error "Failed to retrieve server with ID $id. Error: $_"
                }
            }
        }
        else {
            try {
                Write-Verbose "Getting all servers"
                $allServerUrls = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/servers" @script:XoRestParameters
                
                if ($allServerUrls -and $allServerUrls.Count -gt 0) {
                    Write-Verbose "Found $($allServerUrls.Count) servers"
                    $processLimit = if ($Limit -gt 0) { [Math]::Min($Limit, $allServerUrls.Count) } else { $allServerUrls.Count }
                    $processUrls = $allServerUrls | Select-Object -First $processLimit
                    
                    foreach ($serverUrl in $processUrls) {
                        if ([string]::IsNullOrEmpty($serverUrl)) {
                            Write-Verbose "Skipping empty URL"
                            continue
                        }
                        
                        try {
                            $match = [regex]::Match($serverUrl, "\/rest\/v0\/servers\/([^\/]+)$")
                            if ($match.Success) {
                                $id = $match.Groups[1].Value
                                if (![string]::IsNullOrEmpty($id)) {
                                    $serverDetail = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/servers/$id" @script:XoRestParameters
                                    if ($serverDetail) {
                                        ConvertTo-XoServerObject $serverDetail
                                    }
                                }
                                else {
                                    Write-Warning "Failed to extract valid ID from URL: $serverUrl"
                                }
                            }
                            else {
                                Write-Warning "URL doesn't match expected pattern: $serverUrl"
                            }
                        }
                        catch {
                            Write-Warning "Failed to process server from URL $serverUrl. Error: $_"
                        }
                    }
                    
                    if ($allServerUrls.Count -gt $processLimit) {
                        Write-Warning "Only processed $processLimit of $($allServerUrls.Count) available servers. Use -Limit parameter to adjust."
                    }
                }
                else {
                    Write-Verbose "No servers found"
                }
            }
            catch {
                Write-Error "Failed to retrieve servers: $_"
            }
        }
    }
}

function Enable-XoServer {
    <#
    .SYNOPSIS
        Enable a server in Xen Orchestra.
    .DESCRIPTION
        Enables a server that has been previously disabled in Xen Orchestra.
    .PARAMETER ServerUuid
        The UUID of the server to enable.
    .EXAMPLE
        Enable-XoServer -ServerUuid "12345678-abcd-1234-abcd-1234567890ab"
        Enables the server with the specified UUID.
    .EXAMPLE
        Get-XoServer | Where-Object { -not $_.Enabled } | Enable-XoServer
        Enables all disabled servers.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string[]]$ServerUuid
    )
    
    process {
        foreach ($id in $ServerUuid) {
            if ($PSCmdlet.ShouldProcess($id, "Enable server")) {
                try {
                    Write-Verbose "Enabling server $id"
                    Invoke-RestMethod -Uri "$script:XoHost/rest/v0/servers/$id/enable" -Method Post @script:XoRestParameters
                    Write-Verbose "Server enabled successfully"
                }
                catch {
                    Write-Error "Failed to enable server $id. Error: $_"
                }
            }
        }
    }
}

function Disable-XoServer {
    <#
    .SYNOPSIS
        Disable a server in Xen Orchestra.
    .DESCRIPTION
        Disables a server in Xen Orchestra. Disabled servers are not accessed by Xen Orchestra.
    .PARAMETER ServerUuid
        The UUID of the server to disable.
    .EXAMPLE
        Disable-XoServer -ServerUuid "12345678-abcd-1234-abcd-1234567890ab"
        Disables the server with the specified UUID.
    .EXAMPLE
        Get-XoServer | Where-Object { $_.Enabled } | Disable-XoServer
        Disables all enabled servers.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string[]]$ServerUuid
    )
    
    process {
        foreach ($id in $ServerUuid) {
            if ($PSCmdlet.ShouldProcess($id, "Disable server")) {
                try {
                    Write-Verbose "Disabling server $id"
                    Invoke-RestMethod -Uri "$script:XoHost/rest/v0/servers/$id/disable" -Method Post @script:XoRestParameters
                    Write-Verbose "Server disabled successfully"
                }
                catch {
                    Write-Error "Failed to disable server $id. Error: $_"
                }
            }
        }
    }
}

function Restart-XoServer {
    <#
    .SYNOPSIS
        Restart a server's toolstack in Xen Orchestra.
    .DESCRIPTION
        Restarts the XAPI toolstack on the specified server.
    .PARAMETER ServerUuid
        The UUID of the server to restart the toolstack on.
    .EXAMPLE
        Restart-XoServer -ServerUuid "12345678-abcd-1234-abcd-1234567890ab"
        Restarts the toolstack on the server with the specified UUID.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string[]]$ServerUuid
    )
    
    process {
        foreach ($id in $ServerUuid) {
            if ($PSCmdlet.ShouldProcess($id, "Restart server toolstack")) {
                try {
                    Write-Verbose "Restarting toolstack on server $id"
                    Invoke-RestMethod -Uri "$script:XoHost/rest/v0/servers/$id/restart-toolstack" -Method Post @script:XoRestParameters
                    Write-Verbose "Toolstack restart initiated"
                }
                catch {
                    Write-Error "Failed to restart toolstack for server $id. Error: $_"
                }
            }
        }
    }
} 
# SPDX-License-Identifier: Apache-2.0

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
        [int]$Limit = 25
    )

    begin {
        $params = @{}
        if ($PSBoundParameters.ContainsKey('Filter')) {
            $params['filter'] = $Filter
        }
        
        if ($Limit -ne 0) {
            $params['limit'] = $Limit
            if (!$PSBoundParameters.ContainsKey('Limit')) {
                Write-Warning "No limit specified. Using default limit of 25. Use -Limit 0 for unlimited results."
            }
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
                    throw "Failed to retrieve server with ID $id. Error: $_"
                }
            }
        }
        else {
            try {
                Write-Verbose "Getting servers with parameters: $($params | ConvertTo-Json -Compress)"
                $allServerUrls = Invoke-RestMethod -Uri "$script:XoHost/rest/v0/servers" @script:XoRestParameters -Body $params
                
                if ($allServerUrls -and $allServerUrls.Count -gt 0) {
                    Write-Verbose "Found $($allServerUrls.Count) servers"
                    
                    foreach ($serverUrl in $allServerUrls) {
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
                                    throw "Failed to extract valid ID from URL: $serverUrl"
                                }
                            }
                            else {
                                throw "URL doesn't match expected pattern: $serverUrl"
                            }
                        }
                        catch {
                            throw "Failed to process server from URL $serverUrl. Error: $_"
                        }
                    }
                }
                else {
                    Write-Verbose "No servers found"
                }
            }
            catch {
                throw "Failed to retrieve servers: $_"
            }
        }
    }
}
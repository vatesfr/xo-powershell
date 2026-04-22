# SPDX-License-Identifier: Apache-2.0

function Get-XoServer
{
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
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    # Parameter sets:
    # - "Filter": Gets servers with optional filtering criteria (with optional limit)
    # - "ServerUuid": Gets specific servers by UUID
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "ServerUuid")]
        [Alias("ServerId")]
        [string[]]$ServerUuid,

        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit = $script:XoSessionLimit
    )

    begin
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw ("Not connected to Xen Orchestra. Call Connect-XoSession first.")
        }

        $params = @{ fields = $script:XO_SERVER_FIELDS }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "ServerUuid")
        {
            foreach ($id in $ServerUuid)
            {
                Get-XoSingleServerById -ServerUuid $id -Params $params
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            $AllFilters = $Filter

            if ($AllFilters)
            {
                $params["filter"] = $AllFilters
            }

            if ($Limit)
            {
                $params["limit"] = $Limit
            }

            try
            {
                Write-Verbose "Getting servers with parameters: $($params | ConvertTo-Json -Compress)"
                $uri = "$script:XoHost/rest/v0/servers"
                $response = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params

                if (!$response -or $response.Count -eq 0)
                {
                    Write-Verbose "No servers found matching criteria"
                    return
                }

                Write-Verbose "Found $($response.Count) servers"

                foreach ($serverItem in $response)
                {
                    ConvertTo-XoServerObject -InputObject $serverItem
                }
            }
            catch
            {
                throw ("Failed to list servers. Error: {0}" -f $_)
            }
        }
    }
}

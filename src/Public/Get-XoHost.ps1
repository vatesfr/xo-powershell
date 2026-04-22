# SPDX-License-Identifier: Apache-2.0

function Get-XoHost
{
    <#
    .SYNOPSIS
        Get physical hosts from Xen Orchestra.
    .DESCRIPTION
        Retrieves physical XCP-ng/XenServer hosts from Xen Orchestra.
        Can retrieve specific hosts by their UUID or filter hosts by various criteria.
    .PARAMETER HostUuid
        The UUID(s) of the host(s) to retrieve.
    .PARAMETER Filter
        Filter to apply to the host query.
    .PARAMETER PoolUuid
        UUID of the pool whose hosts to retrieve.
    .PARAMETER Limit
        Maximum number of results to return. Default is 25 if not specified.
    .EXAMPLE
        Get-XoHost
        Returns up to 25 hosts.
    .EXAMPLE
        Get-XoHost -Limit 0
        Returns all hosts without limit.
    .EXAMPLE
        Get-XoHost -HostUuid "12345678-abcd-1234-abcd-1234567890ab"
        Returns the host with the specified UUID.
    .EXAMPLE
        Get-XoHost -Filter "power_state:running"
        Returns running hosts (up to default limit).
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    # Parameter sets:
    # - "Filter": Gets hosts with optional filtering criteria (with optional limit)
    # - "HostUuid": Gets specific hosts by UUID
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "HostUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [Alias("HostId")]
        [string[]]$HostUuid,

        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Filter")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string]$PoolUuid,

        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit = $script:XoSessionLimit
    )

    # use Invoke-XoRestMethod with JSON hashtable fallback in this cmdlet since server may send JSON object with multiple "cpus" keys, which confuses PowerShell when outputting PSObjects

    begin
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw ("Not connected to Xen Orchestra. Call Connect-XoSession first.")
        }

        $params = @{ fields = $script:XO_HOST_FIELDS }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "HostUuid")
        {
            foreach ($id in $HostUuid)
            {
                ConvertTo-XoHostObject (Invoke-XoRestMethod -Uri "$script:XoHost/rest/v0/hosts/$id" -Body $params)
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            $AllFilters = $Filter

            if ($PoolUuid)
            {
                $AllFilters = "$AllFilters `$pool:$PoolUuid"
            }

            if ($AllFilters)
            {
                Write-Verbose "Filter: $AllFilters"
                $params["filter"] = $AllFilters
            }

            if ($Limit)
            {
                $params["limit"] = $Limit
            }

            try
            {
                $uri = "$script:XoHost/rest/v0/hosts"
                $hostsResponse = Invoke-XoRestMethod -Uri $uri -Body $params

                if (!$hostsResponse -or $hostsResponse.Count -eq 0)
                {
                    Write-Verbose "No hosts found"
                    return
                }

                foreach ($hostItem in $hostsResponse)
                {
                    ConvertTo-XoHostObject -InputObject $hostItem
                }
            }
            catch
            {
                throw ("Failed to list hosts. Error: {0}" -f $_)
            }
        }
    }
}

# SPDX-License-Identifier: Apache-2.0

function Get-XoVm
{
    <#
    .SYNOPSIS
        Get VMs from Xen Orchestra.
    .DESCRIPTION
        Retrieves VMs from Xen Orchestra. Can retrieve specific VMs by their UUID
        or filter VMs by power state, tags, or custom filters.
    .PARAMETER VmUuid
        The UUID(s) of the VM(s) to retrieve.
    .PARAMETER PowerState
        Filter VMs by power state. Valid values: Running, Halted, Suspended.
    .PARAMETER Tag
        Filter VMs by one or more tags.
    .PARAMETER Filter
        Custom filter to apply to the VM query.
    .PARAMETER PoolUuid
        UUID of the pool whose VMs to retrieve.
    .PARAMETER HostUuid
        UUID of the host whose VMs to retrieve.
    .PARAMETER Limit
        Maximum number of results to return. Default is 25 if not specified.
    .EXAMPLE
        Get-XoVm
        Returns up to 25 VMs.
    .EXAMPLE
        Get-XoVm -Limit 0
        Returns all VMs without limit.
    .EXAMPLE
        Get-XoVm -VmUuid "12345678-abcd-1234-abcd-1234567890ab"
        Returns the VM with the specified UUID.
    .EXAMPLE
        Get-XoVm -PowerState Running
        Returns running VMs (up to default limit).
    .EXAMPLE
        Get-XoVm -Tag "Production"
        Returns VMs tagged with "Production" (up to default limit).
    .EXAMPLE
        Get-XoVm -Filter "name_label:test*"
        Returns VMs with names starting with "test" (up to default limit).
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "VmUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [Alias("VmId")]
        [string[]]$VmUuid,

        [Parameter(ParameterSetName = "Filter")]
        [ValidateSet("Running", "Halted", "Suspended")]
        [string[]]$PowerState,

        [Parameter(ParameterSetName = "Filter")]
        [string[]]$Tag,

        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Filter")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string]$PoolUuid,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Filter")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string]$HostUuid,

        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit = $script:XoSessionLimit
    )

    begin
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw ("Not connected to Xen Orchestra. Call Connect-XoSession first.")
        }

        $params = @{ fields = $script:XO_VM_FIELDS }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "VmUuid")
        {
            foreach ($id in $VmUuid)
            {
                Get-XoSingleVmById -VmUuid $id
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            $AllFilters = $Filter

            if ($PowerState)
            {
                $AllFilters = "$AllFilters power_state:($($PowerState -join '|'))"
            }

            if ($Tag)
            {
                $AllFilters = "$AllFilters tags:($($Tag -join '&'))"
            }

            if ($PoolUuid)
            {
                $AllFilters = "$AllFilters `$pool:$PoolUuid"
            }

            if ($HostUuid)
            {
                $AllFilters = "$AllFilters `$container:$HostUuid"
            }

            if ($AllFilters)
            {
                Write-Verbose "Filter: $AllFilters"
                $params["filter"] = $AllFilters
            }

            if ($Limit)
            {
                $params['limit'] = $Limit
            }

            try
            {
                $uri = "$script:XoHost/rest/v0/vms"
                Write-Verbose "Getting VMs from $uri with parameters: $($params | ConvertTo-Json -Compress)"

                $response = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params

                if (!$response -or $response.Count -eq 0)
                {
                    Write-Verbose "No VMs found matching criteria"
                    return
                }

                Write-Verbose "Found $($response.Count) VMs"

                foreach ($vmItem in $response)
                {
                    ConvertTo-XoVmObject -InputObject $vmItem
                }
            }
            catch
            {
                throw ("Failed to list VMs. Error: {0}" -f $_)
            }
        }
    }
}

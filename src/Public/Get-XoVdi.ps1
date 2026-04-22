# SPDX-License-Identifier: Apache-2.0

function Get-XoVdi
{
    <#
    .SYNOPSIS
        Get VDIs from Xen Orchestra.
    .DESCRIPTION
        Retrieves VDIs from Xen Orchestra. Can retrieve specific VDIs by their UUID
        or filter VDIs by various criteria.
    .PARAMETER VdiUuid
        The UUID(s) of the VDI(s) to retrieve.
    .PARAMETER SrUuid
        Filter VDIs by storage repository UUID.
    .PARAMETER Filter
        Custom filter to apply to the VDI query.
    .PARAMETER Limit
        Maximum number of results to return. Default is 25 if not specified.
    .EXAMPLE
        Get-XoVdi
        Returns up to 25 VDIs.
    .EXAMPLE
        Get-XoVdi -Limit 0
        Returns all VDIs without limit.
    .EXAMPLE
        Get-XoVdi -VdiUuid "12345678-abcd-1234-abcd-1234567890ab"
        Returns the VDI with the specified UUID.
    .EXAMPLE
        Get-XoVdi -SrUuid "12345678-abcd-1234-abcd-1234567890ab"
        Returns VDIs on the specified storage repository (up to default limit).
    .EXAMPLE
        Get-XoVdi -Filter "name_label:backup*"
        Returns VDIs with names starting with "backup" (up to default limit).
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "VdiUuid")]
        [Alias("VdiId")]
        [string[]]$VdiUuid,

        [Parameter(ParameterSetName = "Filter")]
        [string]$SrUuid,

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

        $params = @{ fields = $script:XO_VDI_FIELDS }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "VdiUuid")
        {
            foreach ($id in $VdiUuid)
            {
                Get-XoSingleVdiById -VdiUuid $id -Params $params
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            $filterParts = @()

            if ($SrUuid)
            {
                $filterParts += "`$SR:$SrUuid"
            }

            if ($Filter)
            {
                $filterParts += $Filter
            }

            if ($filterParts.Count -gt 0)
            {
                $params['filter'] = $filterParts -join " "
            }

            if ($Limit)
            {
                $params['limit'] = $Limit
            }

            try
            {
                Write-Verbose "Getting VDIs with parameters: $($params | ConvertTo-Json -Compress)"
                $uri = "$script:XoHost/rest/v0/vdis"
                $response = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params

                if (!$response -or $response.Count -eq 0)
                {
                    Write-Verbose "No VDIs found matching criteria"
                    return
                }

                Write-Verbose "Found $($response.Count) VDIs"

                foreach ($vdiItem in $response)
                {
                    ConvertTo-XoVdiObject -InputObject $vdiItem
                }
            }
            catch
            {
                throw ("Failed to list VDIs. Error: {0}" -f $_)
            }
        }
    }
}

# SPDX-License-Identifier: Apache-2.0

function Get-XoSr
{
    <#
    .SYNOPSIS
        Get storage repositories from Xen Orchestra.
    .DESCRIPTION
        Retrieves storage repositories from Xen Orchestra. Can retrieve specific SRs by their UUID
        or all SRs.
    .PARAMETER SrUuid
        The UUID(s) of the SR(s) to retrieve.
    .PARAMETER Limit
        Maximum number of results to return. Default is 25 if not specified.
        Use -Limit 0 to return all results without limitation.
    .EXAMPLE
        Get-XoSr
        Returns up to 25 SRs.
    .EXAMPLE
        Get-XoSr -Limit 0
        Returns all SRs without limit.
    .EXAMPLE
        Get-XoSr -SrUuid "a1b2c3d4"
        Returns the SR with the specified UUID.
    .EXAMPLE
        Get-XoSr -Limit 5
        Returns the first 5 SRs.
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    [OutputType("XoPowershell.Sr")]
    # Parameter sets:
    # - "Filter": Gets SRs with optional filtering criteria (with optional limit)
    # - "SrUuid": Gets specific SRs by UUID
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "SrUuid")]
        [ValidatePattern("[0-9a-z-]+")]
        [Alias("SrId")]
        [string[]]$SrUuid,

        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit = $script:XoSessionLimit
    )

    begin
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw ("Not connected to Xen Orchestra. Call Connect-XoSession first.")
        }

        $params = @{
            fields = $script:XO_SR_FIELDS
        }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "SrUuid")
        {
            foreach ($id in $SrUuid)
            {
                Get-XoSingleSrById -SrUuid $id -Params $params
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            if ($Limit)
            {
                $params['limit'] = $Limit
            }

            try
            {
                Write-Verbose "Getting SRs with parameters: $($params | ConvertTo-Json -Compress)"
                $uri = "$script:XoHost/rest/v0/srs"
                $response = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params

                if (!$response -or $response.Count -eq 0)
                {
                    Write-Verbose "No SRs found"
                    return
                }

                Write-Verbose "Found $($response.Count) SRs"

                foreach ($srItem in $response)
                {
                    ConvertTo-XoSrObject -InputObject $srItem
                }
            }
            catch
            {
                throw ("Failed to list SRs. Error: {0}" -f $_)
            }
        }
    }
}

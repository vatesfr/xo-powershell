# SPDX-License-Identifier: Apache-2.0

function Get-XoSingleServerById
{
    <#
    .SYNOPSIS
    Get single server by ID

    .DESCRIPTION
    Get a single server from Xen Orchestra by its ID.

    .PARAMETER ServerUuid
    Target server UUID to retrieve.

    .PARAMETER Params
    Target server query parameters.

    .EXAMPLE
    Get-XoSingleServerById -ServerUuid '812b59e1-2682-43ef-acd4-808d3551b907'
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Server")]
    param (
        [string]$ServerUuid,
        [hashtable]$Params
    )
    process
    {

        try
        {
            Write-Verbose "Getting server with ID $ServerUuid"
            $uri = "$script:XoHost/rest/v0/servers/$ServerUuid"

            if ($null -eq $Params)
            {
                $Params = @{}
            }
            if (-not $Params.ContainsKey('fields'))
            {
                $Params['fields'] = $script:XO_SERVER_FIELDS
            }

            $serverData = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $Params

            if ($serverData)
            {
                return ConvertTo-XoServerObject -InputObject $serverData
            }
        }
        catch
        {
            throw ("Failed to retrieve server with ID {0}: {1}" -f $ServerUuid, $_)
        }
        return $null
    }
}

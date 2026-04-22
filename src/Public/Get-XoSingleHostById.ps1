# SPDX-License-Identifier: Apache-2.0

function Get-XoSingleHostById
{
    <#
    .SYNOPSIS
    Get a single host by ID

    .DESCRIPTION
    Get a single host from Xen Orchestra by its UUID.

    .PARAMETER HostUuid
    Target host UUID to retrieve.

    .PARAMETER Params
    Hashtable with request parameters.

    .EXAMPLE
    Get-XoSingleHostById -HostUuid '812b59e1-2682-43ef-acd4-808d3551b907'
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Host")]
    param (
        [string]$HostUuid,
        [hashtable]$Params
    )
    process
    {

        try
        {
            $uri = "$script:XoHost/rest/v0/hosts/$HostUuid"
            $params = @{ fields = $script:XO_HOST_FIELDS }
            $hostData = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params

            if ($hostData)
            {
                return ConvertTo-XoHostObject -InputObject $hostData
            }
        }
        catch
        {
            throw ("Failed to retrieve host with UUID {0}: {1}" -f $HostUuid, $_)
        }
    }
}

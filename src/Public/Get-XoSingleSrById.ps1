# SPDX-License-Identifier: Apache-2.0

function Get-XoSingleSrById
{
    <#
    .SYNOPSIS
    Get single SR by ID

    .DESCRIPTION
    Get a single storage repository by its UUID.

    .PARAMETER SrUuid
    Target storage repository UUID.

    .PARAMETER Params
    Target SR request parameters hash.

    .EXAMPLE
    Get-XoSingleSrById -SrUuid '812b59e1-2682-43ef-acd4-808d3551b907'
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Sr")]
    param (
        [string]$SrUuid,
        [hashtable]$Params
    )
    process
    {

        try
        {
            Write-Verbose "Getting SR with UUID $SrUuid"
            $uri = "$script:XoHost/rest/v0/srs/$SrUuid"
            $srData = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $Params

            if ($srData)
            {
                return ConvertTo-XoSrObject -InputObject $srData
            }
        }
        catch
        {
            throw ("Failed to retrieve SR with UUID {0}: {1}" -f $SrUuid, $_)
        }
        return $null
    }
}

# SPDX-License-Identifier: Apache-2.0

function Get-XoSingleVdiById
{
    <#
    .SYNOPSIS
    Get VDI by ID

    .DESCRIPTION
    Get a single VDI from Xen Orchestra by UUID.

    .PARAMETER VdiUuid
    Target VDI UUID to retrieve.

    .PARAMETER Params
    Target VDI request parameters hash.

    .EXAMPLE
    Get-XoSingleVdiById -VdiUuid '812b59e1-2682-43ef-acd4-808d3551b907'
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Vdi")]
    param (
        [string]$VdiUuid,
        [hashtable]$Params
    )
    process
    {

        try
        {
            Write-Verbose "Getting VDI with UUID $VdiUuid"
            $uri = "$script:XoHost/rest/v0/vdis/$VdiUuid"
            $vdiData = Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $Params

            if ($vdiData)
            {
                return ConvertTo-XoVdiObject -InputObject $vdiData
            }
        }
        catch
        {
            throw ("Failed to retrieve VDI with UUID {0}: {1}" -f $VdiUuid, $_)
        }
        return $null
    }
}

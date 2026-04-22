# SPDX-License-Identifier: Apache-2.0

function Get-XoPbd
{
    <#
    .SYNOPSIS
        List or query Xen Orchestra PBDs.
    .DESCRIPTION
        Retrieves physical block devices (PBDs). A PBD is the XAPI object that connects a host to a storage repository. When called without parameters the cmdlet returns up to the session-wide limit (see Set-XoSession); supply -PbdUuid to fetch specific entries or -Filter / -Limit to scope a list query.
    .PARAMETER PbdUuid
        One or more IDs of the PBDs to retrieve. When omitted, the cmdlet enumerates PBDs using Filter and Limit.
    .PARAMETER Filter
        XO filter expression applied server-side (same syntax as the REST `filter` query parameter, e.g. `status:success`).
    .PARAMETER Limit
        Maximum number of PBDs to return when listing. Defaults to the session limit set by Connect-XoSession or Set-XoSession.
    .EXAMPLE
        Get-XoPbd | Where-Object attached -eq $false
    .EXAMPLE
        Get-XoPbd -PbdUuid "<id>"
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    [OutputType("XoPowershell.Pbd")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "PbdUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$PbdUuid,

        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit = $script:XoSessionLimit
    )

    begin
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }

        $params = @{}
        $params["fields"] = $script:XO_PBD_FIELDS
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "PbdUuid")
        {
            foreach ($id in $PbdUuid)
            {
                $uri = "$script:XoHost/rest/v0/pbds/$id"
                ConvertTo-XoPbdObject (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params)
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            if ($Filter) { $params["filter"] = $Filter }
            if ($Limit)  { $params["limit"] = $Limit }

            $uri = "$script:XoHost/rest/v0/pbds"
            # the parentheses forces the resulting array to unpack, don't remove them!
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoPbdObject
        }
    }
}


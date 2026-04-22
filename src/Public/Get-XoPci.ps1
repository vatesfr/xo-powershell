# SPDX-License-Identifier: Apache-2.0

function Get-XoPci
{
    <#
    .SYNOPSIS
        List or query Xen Orchestra PCI devices.
    .DESCRIPTION
        Retrieves PCI devices visible to pool hosts. Useful for discovering devices available for passthrough. When called without parameters the cmdlet returns up to the session-wide limit (see Set-XoSession); supply -PciUuid to fetch specific entries or -Filter / -Limit to scope a list query.
    .PARAMETER PciUuid
        One or more IDs of the PCI devices to retrieve. When omitted, the cmdlet enumerates PCI devices using Filter and Limit.
    .PARAMETER Filter
        XO filter expression applied server-side (same syntax as the REST `filter` query parameter, e.g. `status:success`).
    .PARAMETER Limit
        Maximum number of PCI devices to return when listing. Defaults to the session limit set by Connect-XoSession or Set-XoSession.
    .EXAMPLE
        Get-XoPci -Limit 0
    .EXAMPLE
        Get-XoPci -PciUuid "<id>"
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    [OutputType("XoPowershell.Pci")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "PciUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$PciUuid,

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
        $params["fields"] = $script:XO_PCI_FIELDS
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "PciUuid")
        {
            foreach ($id in $PciUuid)
            {
                $uri = "$script:XoHost/rest/v0/pcis/$id"
                ConvertTo-XoPciObject (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params)
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            if ($Filter) { $params["filter"] = $Filter }
            if ($Limit)  { $params["limit"] = $Limit }

            $uri = "$script:XoHost/rest/v0/pcis"
            # the parentheses forces the resulting array to unpack, don't remove them!
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoPciObject
        }
    }
}


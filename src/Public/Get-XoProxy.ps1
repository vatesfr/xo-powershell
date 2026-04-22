# SPDX-License-Identifier: Apache-2.0

function Get-XoProxy
{
    <#
    .SYNOPSIS
        List or query Xen Orchestra XO proxies.
    .DESCRIPTION
        Retrieves Xen Orchestra proxies - lightweight VMs that relay backup/migration traffic between XO and a pool. When called without parameters the cmdlet returns up to the session-wide limit (see Set-XoSession); supply -ProxyId to fetch specific entries or -Filter / -Limit to scope a list query.
    .PARAMETER ProxyId
        One or more IDs of the XO proxies to retrieve. When omitted, the cmdlet enumerates XO proxies using Filter and Limit.
    .PARAMETER Filter
        XO filter expression applied server-side (same syntax as the REST `filter` query parameter, e.g. `status:success`).
    .PARAMETER Limit
        Maximum number of XO proxies to return when listing. Defaults to the session limit set by Connect-XoSession or Set-XoSession.
    .EXAMPLE
        Get-XoProxy
    .EXAMPLE
        Get-XoProxy -ProxyId "<id>"
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    [OutputType("XoPowershell.Proxy")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "ProxyId")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$ProxyId,

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
        $params["fields"] = $script:XO_PROXY_FIELDS
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "ProxyId")
        {
            foreach ($id in $ProxyId)
            {
                $uri = "$script:XoHost/rest/v0/proxies/$id"
                ConvertTo-XoProxyObject (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params)
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            if ($Filter) { $params["filter"] = $Filter }
            if ($Limit)  { $params["limit"] = $Limit }

            $uri = "$script:XoHost/rest/v0/proxies"
            # the parentheses forces the resulting array to unpack, don't remove them!
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoProxyObject
        }
    }
}


# SPDX-License-Identifier: Apache-2.0

function Get-XoEvent
{
    <#
    .SYNOPSIS
        List Xen Orchestra events.
    .DESCRIPTION
        Retrieves entries from the Xen Orchestra event log. Events represent system-level occurrences (object changes, connection events, user actions). Useful for audit/troubleshooting. Supports XO filter expressions and paging.
    .PARAMETER Filter
        XO filter expression applied server-side (e.g. `type:host`).
    .PARAMETER Limit
        Maximum number of events to return. Defaults to the session limit.
    .EXAMPLE
        Get-XoEvent -Limit 100
    .EXAMPLE
        Get-XoEvent -Filter 'type:connection-lost'
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Event")]
    param (
        [Parameter()]
        [string]$Filter,

        [Parameter()]
        [int]$Limit = $script:XoSessionLimit
    )

    process
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }

        $params = @{}
        $params["fields"] = $script:XO_EVENT_FIELDS
        if ($Filter)   { $params["filter"] = $Filter }
        if ($Limit)    { $params["limit"] = $Limit }

        $uri = "$script:XoHost/rest/v0/events"
        (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoEventObject
    }
}


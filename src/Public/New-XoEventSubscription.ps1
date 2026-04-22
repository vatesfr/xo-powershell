# SPDX-License-Identifier: Apache-2.0

function New-XoEventSubscription
{
    <#
    .SYNOPSIS
        Create a new subscription on a Xen Orchestra event.
    .DESCRIPTION
        Calls POST /events/{id}/subscriptions to register a subscription that pushes filtered collection updates to the caller.
    .PARAMETER EventId
        The ID of the event to subscribe to.
    .PARAMETER Collection
        XO collection to watch (e.g. 'VM').
    .PARAMETER Fields
        Fields to include in notification payloads.
    .EXAMPLE
        New-XoEventSubscription -EventId "events" -Collection "VM" -Fields id,name_label
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$EventId,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Collection,

        [Parameter()]
        [string[]]$Fields
    )

    begin
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }
    }

    process
    {
        if (-not $PSCmdlet.ShouldProcess($EventId, "add subscription"))
        {
            return
        }

        $body = @{ collection = $Collection }
        if ($PSBoundParameters.ContainsKey("Fields")) { $body["fields"] = @($Fields) }

        $bodyJson  = ConvertTo-Json -InputObject $body -Depth 5 -Compress
        $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyJson)

        $uri = "$script:XoHost/rest/v0/events/$EventId/subscriptions"
        Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters -ContentType "application/json" -Body $bodyBytes
    }
}

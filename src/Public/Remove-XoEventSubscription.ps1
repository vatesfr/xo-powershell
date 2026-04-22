# SPDX-License-Identifier: Apache-2.0

function Remove-XoEventSubscription
{
    <#
    .SYNOPSIS
        Remove a subscription from a Xen Orchestra event.
    .DESCRIPTION
        Calls DELETE /events/{id}/subscriptions/{subscriptionId} to detach a subscription previously registered with New-XoEventSubscription.
    .PARAMETER EventId
        The ID of the event that the subscription belongs to.
    .PARAMETER SubscriptionId
        The ID of the subscription to remove.
    .EXAMPLE
        Remove-XoEventSubscription -EventId "events" -SubscriptionId "sub-123"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$EventId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$SubscriptionId
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
        if (-not $PSCmdlet.ShouldProcess("event $EventId", "remove subscription $SubscriptionId"))
        {
            return
        }

        $uri = "$script:XoHost/rest/v0/events/$EventId/subscriptions/$SubscriptionId"
        Invoke-RestMethod -Uri $uri -Method Delete @script:XoRestParameters
    }
}

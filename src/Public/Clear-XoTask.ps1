# SPDX-License-Identifier: Apache-2.0

function Clear-XoTask
{
    <#
    .SYNOPSIS
        Delete all Xen Orchestra tasks (bulk cleanup).
    .DESCRIPTION
        Issues DELETE /tasks. Used to purge the task log. Typically invoked with -Filter to scope to completed/failed tasks only; check the XO REST documentation for the exact filter semantics supported on this endpoint.
    .PARAMETER Filter
        Optional filter expression forwarded to the server.
    .EXAMPLE
        Clear-XoTask -Filter 'status:success'
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter()]
        [string]$Filter
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
        if (-not $PSCmdlet.ShouldProcess("all tasks", "bulk delete"))
        {
            return
        }

        $body = @{}
        if ($Filter) { $body["filter"] = $Filter }

        $uri = "$script:XoHost/rest/v0/tasks"
        Invoke-RestMethod -Uri $uri -Method Delete @script:XoRestParameters -Body $body
    }
}

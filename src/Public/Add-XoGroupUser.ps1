# SPDX-License-Identifier: Apache-2.0

function Add-XoGroupUser
{
    <#
    .SYNOPSIS
        Add an existing user to a Xen Orchestra group.
    .DESCRIPTION
        Associates a user with a group via PUT /groups/{id}/users/{userId}. The user must already exist (see New-XoUser). This is an idempotent operation - re-adding an already-member user is a no-op on the server.
    .PARAMETER GroupId
        The UUID of the group the user will be added to.
    .PARAMETER UserId
        The UUID of the user to add to the group.
    .EXAMPLE
        Add-XoGroupUser -GroupId "7d98fee4-3357-41a7-ac3f-9124212badb7" -UserId "722d17b9-699b-49d2-8193-be1ac573d3de"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string]$GroupId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string]$UserId
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
        if (-not $PSCmdlet.ShouldProcess("group $GroupId", "add user $UserId"))
        {
            return
        }

        $uri = "$script:XoHost/rest/v0/groups/$GroupId/users/$UserId"
        Invoke-RestMethod -Uri $uri -Method Put @script:XoRestParameters
    }
}

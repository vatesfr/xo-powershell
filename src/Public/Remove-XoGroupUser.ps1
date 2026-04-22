# SPDX-License-Identifier: Apache-2.0

function Remove-XoGroupUser
{
    <#
    .SYNOPSIS
        Remove a user from a Xen Orchestra group.
    .DESCRIPTION
        Disassociates a user from a group via DELETE /groups/{id}/users/{userId}. The user itself is not deleted - only the membership is removed.
    .PARAMETER GroupId
        The UUID of the group to remove the user from.
    .PARAMETER UserId
        The UUID of the user to remove from the group.
    .EXAMPLE
        Remove-XoGroupUser -GroupId "7d98fee4-3357-41a7-ac3f-9124212badb7" -UserId "722d17b9-699b-49d2-8193-be1ac573d3de"
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
        if (-not $PSCmdlet.ShouldProcess("group $GroupId", "remove user $UserId"))
        {
            return
        }

        $uri = "$script:XoHost/rest/v0/groups/$GroupId/users/$UserId"
        Invoke-RestMethod -Uri $uri -Method Delete @script:XoRestParameters
    }
}

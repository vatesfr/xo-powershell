# SPDX-License-Identifier: Apache-2.0

function Get-XoUserAuthenticationToken
{
    <#
    .SYNOPSIS
        List authentication tokens for a specific user.
    .DESCRIPTION
        Retrieves the API authentication tokens owned by a user via GET /users/{id}/authentication_tokens. Each token includes the client id, description, creation/expiration timestamps and most recent use. Useful for auditing long-lived tokens created via xo-cli. The REST API does not expose a "self" variant for listing (only for creation), so a UserId is required.
    .PARAMETER UserId
        The UUID of the user whose authentication tokens should be returned.
    .EXAMPLE
        Get-XoUserAuthenticationToken -UserId '722d17b9-699b-49d2-8193-be1ac573d3de'
    .EXAMPLE
        Get-XoUser | Get-XoUserAuthenticationToken
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.UserAuthenticationToken")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$UserId
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
        foreach ($id in $UserId)
        {
            $uri = "$script:XoHost/rest/v0/users/$id/authentication_tokens"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters) | ConvertTo-XoUserAuthenticationTokenObject
        }
    }
}

# SPDX-License-Identifier: Apache-2.0

function Get-XoGroupUser
{
    <#
    .SYNOPSIS
        Get user scoped to a specific group.
    .DESCRIPTION
        Retrieves user attached to the specified Xen Orchestra group. Accepts one or more group UUIDs; each is queried independently and the combined results are returned.
    .PARAMETER GroupId
        The UUID(s) of the group whose user should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoGroupUser -GroupId "00000000-0000-0000-0000-000000000000"
    .EXAMPLE
        Get-XoGroup | Get-XoGroupUser
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.User")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$GroupId
    )

    begin
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }

        $params = @{}
        $params["fields"] = $script:XO_USER_FIELDS
    }

    process
    {
        foreach ($id in $GroupId)
        {
            $uri = "$script:XoHost/rest/v0/groups/$id/users"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoUserObject
        }
    }
}


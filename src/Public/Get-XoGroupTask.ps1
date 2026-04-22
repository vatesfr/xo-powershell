# SPDX-License-Identifier: Apache-2.0

function Get-XoGroupTask
{
    <#
    .SYNOPSIS
        Get tasks scoped to a specific group.
    .DESCRIPTION
        Retrieves tasks attached to the specified Xen Orchestra group. Accepts one or more group UUIDs; each is queried independently and the combined results are returned.
    .PARAMETER GroupId
        The UUID(s) of the group whose tasks should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoGroupTask -GroupId "00000000-0000-0000-0000-000000000000"
    .EXAMPLE
        Get-XoGroup | Get-XoGroupTask
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Task")]
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
        $params["fields"] = $script:XO_TASK_FIELDS
    }

    process
    {
        foreach ($id in $GroupId)
        {
            $uri = "$script:XoHost/rest/v0/groups/$id/tasks"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoTaskObject
        }
    }
}


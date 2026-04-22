# SPDX-License-Identifier: Apache-2.0

function Get-XoUserTask
{
    <#
    .SYNOPSIS
        Get tasks scoped to a specific user.
    .DESCRIPTION
        Retrieves tasks attached to the specified Xen Orchestra user. Accepts one or more user UUIDs; each is queried independently and the combined results are returned.
    .PARAMETER UserId
        The UUID(s) of the user whose tasks should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoUserTask -UserId "00000000-0000-0000-0000-000000000000"
    .EXAMPLE
        Get-XoUser | Get-XoUserTask
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Task")]
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

        $params = @{}
        $params["fields"] = $script:XO_TASK_FIELDS
    }

    process
    {
        foreach ($id in $UserId)
        {
            $uri = "$script:XoHost/rest/v0/users/$id/tasks"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoTaskObject
        }
    }
}


# SPDX-License-Identifier: Apache-2.0

function Get-XoServerTask
{
    <#
    .SYNOPSIS
        Get tasks scoped to a specific XO server.
    .DESCRIPTION
        Retrieves tasks attached to the specified Xen Orchestra XO server. Accepts one or more XO server UUIDs; each is queried independently and the combined results are returned.
    .PARAMETER ServerUuid
        The UUID(s) of the XO server whose tasks should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoServerTask -ServerUuid "00000000-0000-0000-0000-000000000000"
    .EXAMPLE
        Get-XoServer | Get-XoServerTask
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Task")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$ServerUuid
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
        foreach ($id in $ServerUuid)
        {
            $uri = "$script:XoHost/rest/v0/servers/$id/tasks"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoTaskObject
        }
    }
}


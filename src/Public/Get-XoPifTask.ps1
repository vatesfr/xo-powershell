# SPDX-License-Identifier: Apache-2.0

function Get-XoPifTask
{
    <#
    .SYNOPSIS
        Get tasks scoped to a specific PIF.
    .DESCRIPTION
        Retrieves tasks attached to the specified Xen Orchestra PIF. Accepts one or more PIF UUIDs; each is queried independently and the combined results are returned.
    .PARAMETER PifUuid
        The UUID(s) of the PIF whose tasks should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoPifTask -PifUuid "00000000-0000-0000-0000-000000000000"
    .EXAMPLE
        Get-XoPif | Get-XoPifTask
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Task")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$PifUuid
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
        foreach ($id in $PifUuid)
        {
            $uri = "$script:XoHost/rest/v0/pifs/$id/tasks"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoTaskObject
        }
    }
}


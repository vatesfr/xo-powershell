# SPDX-License-Identifier: Apache-2.0

function Get-XoSrTask
{
    <#
    .SYNOPSIS
        Get tasks scoped to a specific storage repository.
    .DESCRIPTION
        Retrieves tasks attached to the specified Xen Orchestra storage repository. Accepts one or more storage repository UUIDs; each is queried independently and the combined results are returned.
    .PARAMETER SrUuid
        The UUID(s) of the storage repository whose tasks should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoSrTask -SrUuid "00000000-0000-0000-0000-000000000000"
    .EXAMPLE
        Get-XoSr | Get-XoSrTask
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Task")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$SrUuid
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
        foreach ($id in $SrUuid)
        {
            $uri = "$script:XoHost/rest/v0/srs/$id/tasks"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoTaskObject
        }
    }
}


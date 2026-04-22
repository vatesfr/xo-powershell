# SPDX-License-Identifier: Apache-2.0

function Get-XoVdiSnapshotTask
{
    <#
    .SYNOPSIS
        Get tasks scoped to a specific VDI snapshot.
    .DESCRIPTION
        Retrieves tasks attached to the specified Xen Orchestra VDI snapshot. Accepts one or more VDI snapshot UUIDs; each is queried independently and the combined results are returned.
    .PARAMETER VdiSnapshotUuid
        The UUID(s) of the VDI snapshot whose tasks should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoVdiSnapshotTask -VdiSnapshotUuid "00000000-0000-0000-0000-000000000000"
    .EXAMPLE
        Get-XoVdiSnapshot | Get-XoVdiSnapshotTask
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Task")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$VdiSnapshotUuid
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
        foreach ($id in $VdiSnapshotUuid)
        {
            $uri = "$script:XoHost/rest/v0/vdi-snapshots/$id/tasks"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoTaskObject
        }
    }
}


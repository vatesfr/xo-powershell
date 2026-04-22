# SPDX-License-Identifier: Apache-2.0

function Get-XoVbdTask
{
    <#
    .SYNOPSIS
        Get tasks scoped to a specific VBD.
    .DESCRIPTION
        Retrieves tasks attached to the specified Xen Orchestra VBD. Accepts one or more VBD UUIDs; each is queried independently and the combined results are returned.
    .PARAMETER VbdUuid
        The UUID(s) of the VBD whose tasks should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoVbdTask -VbdUuid "00000000-0000-0000-0000-000000000000"
    .EXAMPLE
        Get-XoVbd | Get-XoVbdTask
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Task")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$VbdUuid
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
        foreach ($id in $VbdUuid)
        {
            $uri = "$script:XoHost/rest/v0/vbds/$id/tasks"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoTaskObject
        }
    }
}


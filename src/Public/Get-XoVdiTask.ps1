# SPDX-License-Identifier: Apache-2.0

function Get-XoVdiTask
{
    <#
    .SYNOPSIS
        Get tasks scoped to a specific VDI.
    .DESCRIPTION
        Retrieves tasks attached to the specified Xen Orchestra VDI. Accepts one or more VDI UUIDs; each is queried independently and the combined results are returned.
    .PARAMETER VdiUuid
        The UUID(s) of the VDI whose tasks should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoVdiTask -VdiUuid "00000000-0000-0000-0000-000000000000"
    .EXAMPLE
        Get-XoVdi | Get-XoVdiTask
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Task")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$VdiUuid
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
        foreach ($id in $VdiUuid)
        {
            $uri = "$script:XoHost/rest/v0/vdis/$id/tasks"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoTaskObject
        }
    }
}


# SPDX-License-Identifier: Apache-2.0

function Get-XoVifTask
{
    <#
    .SYNOPSIS
        Get tasks scoped to a specific VIF.
    .DESCRIPTION
        Retrieves tasks attached to the specified Xen Orchestra VIF. Accepts one or more VIF UUIDs; each is queried independently and the combined results are returned.
    .PARAMETER VifUuid
        The UUID(s) of the VIF whose tasks should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoVifTask -VifUuid "00000000-0000-0000-0000-000000000000"
    .EXAMPLE
        Get-XoVif | Get-XoVifTask
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Task")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$VifUuid
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
        foreach ($id in $VifUuid)
        {
            $uri = "$script:XoHost/rest/v0/vifs/$id/tasks"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoTaskObject
        }
    }
}


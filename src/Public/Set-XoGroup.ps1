# SPDX-License-Identifier: Apache-2.0

function Set-XoGroup
{
    <#
    .SYNOPSIS
        Update a Xen Orchestra group.
    .DESCRIPTION
        Renames an existing group via PATCH /groups/{id}.
    .PARAMETER GroupId
        The UUID of the group to update.
    .PARAMETER Name
        The new name for the group.
    .EXAMPLE
        Set-XoGroup -GroupId "7d98fee4-3357-41a7-ac3f-9124212badb7" -Name "ops-team"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string]$GroupId,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    begin
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }
    }

    process
    {
        if (-not $PSCmdlet.ShouldProcess($GroupId, "rename group to '$Name'"))
        {
            return
        }

        $params = @{ name = $Name }
        $bodyJson  = ConvertTo-Json -InputObject $params -Depth 3 -Compress
        $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyJson)

        $uri = "$script:XoHost/rest/v0/groups/$GroupId"
        Invoke-RestMethod -Uri $uri -Method Patch @script:XoRestParameters -ContentType "application/json" -Body $bodyBytes
    }
}

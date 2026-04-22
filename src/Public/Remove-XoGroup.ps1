# SPDX-License-Identifier: Apache-2.0

function Remove-XoGroup
{
    <#
    .SYNOPSIS
        Delete one or more Xen Orchestra groups.
    .DESCRIPTION
        Issues DELETE /groups/{id}. Members are not deleted - only the group itself is removed.
    .PARAMETER GroupId
        The UUID(s) of the group(s) to delete.
    .EXAMPLE
        Remove-XoGroup -GroupId "7d98fee4-3357-41a7-ac3f-9124212badb7"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string[]]$GroupId
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
        foreach ($id in $GroupId)
        {
            if ($PSCmdlet.ShouldProcess($id, "delete group"))
            {
                $uri = "$script:XoHost/rest/v0/groups/$id"
                Invoke-RestMethod -Uri $uri -Method Delete @script:XoRestParameters
            }
        }
    }
}

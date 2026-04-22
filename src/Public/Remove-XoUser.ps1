# SPDX-License-Identifier: Apache-2.0

function Remove-XoUser
{
    <#
    .SYNOPSIS
        Delete one or more Xen Orchestra users.
    .DESCRIPTION
        Issues DELETE /users/{id}. Accepts multiple UUIDs and pipeline input by property name.
    .PARAMETER UserId
        The UUID(s) of the user(s) to delete.
    .EXAMPLE
        Remove-XoUser -UserId "722d17b9-699b-49d2-8193-be1ac573d3de"
    .EXAMPLE
        Get-XoUser | Where-Object permission -eq 'none' | Remove-XoUser
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string[]]$UserId
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
        foreach ($id in $UserId)
        {
            if ($PSCmdlet.ShouldProcess($id, "delete user"))
            {
                $uri = "$script:XoHost/rest/v0/users/$id"
                Invoke-RestMethod -Uri $uri -Method Delete @script:XoRestParameters
            }
        }
    }
}

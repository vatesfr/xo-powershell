# SPDX-License-Identifier: Apache-2.0

function Remove-XoVbd
{
    <#
    .SYNOPSIS
        Delete one or more Xen Orchestra VBDs.
    .DESCRIPTION
        Issues DELETE /vbds/{id}. Accepts multiple IDs and pipeline input by property name.
    .PARAMETER VbdUuid
        The ID(s) of the VBD(s) to delete.
    .EXAMPLE
        Remove-XoVbd -VbdUuid "<id>"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string[]]$VbdUuid
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
        foreach ($id in $VbdUuid)
        {
            if ($PSCmdlet.ShouldProcess($id, "delete VBD"))
            {
                $uri = "$script:XoHost/rest/v0/vbds/$id"
                Invoke-RestMethod -Uri $uri -Method Delete @script:XoRestParameters
            }
        }
    }
}

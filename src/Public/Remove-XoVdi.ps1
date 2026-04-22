# SPDX-License-Identifier: Apache-2.0

function Remove-XoVdi
{
    <#
    .SYNOPSIS
        Delete one or more Xen Orchestra VDIs.
    .DESCRIPTION
        Issues DELETE /vdis/{id}. Accepts multiple IDs and pipeline input by property name.
    .PARAMETER VdiUuid
        The ID(s) of the VDI(s) to delete.
    .EXAMPLE
        Remove-XoVdi -VdiUuid "<id>"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string[]]$VdiUuid
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
        foreach ($id in $VdiUuid)
        {
            if ($PSCmdlet.ShouldProcess($id, "delete VDI"))
            {
                $uri = "$script:XoHost/rest/v0/vdis/$id"
                Invoke-RestMethod -Uri $uri -Method Delete @script:XoRestParameters
            }
        }
    }
}

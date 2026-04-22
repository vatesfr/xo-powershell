# SPDX-License-Identifier: Apache-2.0

function Remove-XoVif
{
    <#
    .SYNOPSIS
        Delete one or more Xen Orchestra VIFs.
    .DESCRIPTION
        Issues DELETE /vifs/{id}. Accepts multiple IDs and pipeline input by property name.
    .PARAMETER VifUuid
        The ID(s) of the VIF(s) to delete.
    .EXAMPLE
        Remove-XoVif -VifUuid "<id>"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string[]]$VifUuid
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
        foreach ($id in $VifUuid)
        {
            if ($PSCmdlet.ShouldProcess($id, "delete VIF"))
            {
                $uri = "$script:XoHost/rest/v0/vifs/$id"
                Invoke-RestMethod -Uri $uri -Method Delete @script:XoRestParameters
            }
        }
    }
}

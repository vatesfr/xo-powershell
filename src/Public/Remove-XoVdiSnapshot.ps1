# SPDX-License-Identifier: Apache-2.0

function Remove-XoVdiSnapshot
{
    <#
    .SYNOPSIS
        Delete one or more Xen Orchestra VDI snapshots.
    .DESCRIPTION
        Issues DELETE /vdi-snapshots/{id}. Accepts multiple IDs and pipeline input by property name.
    .PARAMETER VdiSnapshotUuid
        The ID(s) of the VDI snapshot(s) to delete.
    .EXAMPLE
        Remove-XoVdiSnapshot -VdiSnapshotUuid "<id>"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string[]]$VdiSnapshotUuid
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
        foreach ($id in $VdiSnapshotUuid)
        {
            if ($PSCmdlet.ShouldProcess($id, "delete VDI snapshot"))
            {
                $uri = "$script:XoHost/rest/v0/vdi-snapshots/$id"
                Invoke-RestMethod -Uri $uri -Method Delete @script:XoRestParameters
            }
        }
    }
}

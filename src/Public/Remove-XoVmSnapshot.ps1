# SPDX-License-Identifier: Apache-2.0

function Remove-XoVmSnapshot
{
    <#
    .SYNOPSIS
        Delete one or more Xen Orchestra VM snapshots.
    .DESCRIPTION
        Issues DELETE /vm-snapshots/{id}. Accepts multiple IDs and pipeline input by property name.
    .PARAMETER VmSnapshotUuid
        The ID(s) of the VM snapshot(s) to delete.
    .EXAMPLE
        Remove-XoVmSnapshot -VmSnapshotUuid "<id>"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string[]]$VmSnapshotUuid
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
        foreach ($id in $VmSnapshotUuid)
        {
            if ($PSCmdlet.ShouldProcess($id, "delete VM snapshot"))
            {
                $uri = "$script:XoHost/rest/v0/vm-snapshots/$id"
                Invoke-RestMethod -Uri $uri -Method Delete @script:XoRestParameters
            }
        }
    }
}

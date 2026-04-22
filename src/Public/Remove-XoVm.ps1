# SPDX-License-Identifier: Apache-2.0

function Remove-XoVm
{
    <#
    .SYNOPSIS
        Delete one or more Xen Orchestra VMs.
    .DESCRIPTION
        Issues DELETE /vms/{id}. The VM must be shut down before it can be deleted. Associated VDIs are destroyed along with the VM unless detached first. Accepts multiple UUIDs and pipeline input by property name.
    .PARAMETER VmUuid
        The UUID(s) of the VM(s) to delete.
    .EXAMPLE
        Remove-XoVm -VmUuid "613f541c-4bed-fc77-7ca8-2db6b68f079c"
    .EXAMPLE
        Get-XoVm -PowerState Halted | Where-Object Name -like 'tmp-*' | Remove-XoVm
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string[]]$VmUuid
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
        foreach ($id in $VmUuid)
        {
            if ($PSCmdlet.ShouldProcess($id, "delete VM"))
            {
                $uri = "$script:XoHost/rest/v0/vms/$id"
                Invoke-RestMethod -Uri $uri -Method Delete @script:XoRestParameters
            }
        }
    }
}

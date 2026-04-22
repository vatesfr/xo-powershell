# SPDX-License-Identifier: Apache-2.0

function Get-XoVmVdi
{
    <#
    .SYNOPSIS
        Get virtual disks attached to a VM.
    .DESCRIPTION
        Retrieves all virtual disk images (VDIs) attached to a specified VM.
    .PARAMETER VmUuid
        The UUID of the VM to get VDIs for.
    .EXAMPLE
        Get-XoVmVdi -VmUuid "12345678-abcd-1234-abcd-1234567890ab"
        Returns all virtual disks attached to the specified VM.
    .EXAMPLE
        Get-XoVm -PowerState Running | Get-XoVmVdi
        Returns all virtual disks attached to running VMs.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$VmUuid
    )

    begin
    {
        $params = @{
            fields = $script:XO_VDI_FIELDS
        }
    }

    process
    {
        foreach ($id in $VmUuid)
        {
            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$id/vdis" @script:XoRestParameters -Body $params) | ConvertTo-XoVdiObject
        }
    }
}

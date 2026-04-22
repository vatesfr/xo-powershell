# SPDX-License-Identifier: Apache-2.0

function Suspend-XoVm
{
    <#
    .SYNOPSIS
        Suspend one or more VMs.
    .DESCRIPTION
        Suspends the specified Xen Orchestra VMs.
    .PARAMETER VmUuid
        The UUID(s) of the VM(s) to suspend.
    .EXAMPLE
        Suspend-XoVm -VmUuid "12345678-abcd-1234-abcd-1234567890ab"
        Suspends the VM with the specified UUID.
    .EXAMPLE
        Get-XoVm -PowerState Running | Suspend-XoVm
        Suspends all running VMs.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$VmUuid
    )

    process
    {
        foreach ($id in $VmUuid)
        {
            if ($PSCmdlet.ShouldProcess($id, "suspend"))
            {
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$id/actions/suspend" -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}

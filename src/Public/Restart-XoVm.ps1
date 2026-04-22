# SPDX-License-Identifier: Apache-2.0

function Restart-XoVm
{
    <#
    .SYNOPSIS
        Restart one or more VMs.
    .DESCRIPTION
        Restarts the specified VMs. By default, performs a clean reboot.
        Use -Force to perform a hard reboot.
    .PARAMETER VmUuid
        The UUID(s) of the VM(s) to restart.
    .PARAMETER Force
        If specified, performs a hard reboot instead of a clean reboot.
    .EXAMPLE
        Restart-XoVm -VmUuid "12345678-abcd-1234-abcd-1234567890ab"
        Performs a clean reboot of the VM with the specified UUID.
    .EXAMPLE
        Get-XoVm -PowerState Running | Restart-XoVm -Force
        Performs a hard reboot of all running VMs.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$VmUuid,
        [Parameter()][switch]$Force
    )

    begin
    {
        $action = if ($Force)
        {
            "hard_reboot"
        }
        else
        {
            "clean_reboot"
        }
    }

    process
    {
        foreach ($id in $VmUuid)
        {
            if ($PSCmdlet.ShouldProcess($id, $action))
            {
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$id/actions/$action" -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}

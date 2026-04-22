# SPDX-License-Identifier: Apache-2.0

function Start-XoVm
{
    <#
    .SYNOPSIS
        Start one or more VMs.
    .DESCRIPTION
        Starts the specified VMs. Returns a task object that can be used to monitor
        the startup operation.
    .PARAMETER VmUuid
        The UUID(s) of the VM(s) to start.
    .EXAMPLE
        Start-XoVm -VmUuid "12345678-abcd-1234-abcd-1234567890ab"
        Starts the VM with the specified UUID.
    .EXAMPLE
        Get-XoVm -PowerState Halted | Start-XoVm
        Starts all halted VMs.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$VmUuid
    )

    process
    {
        foreach ($id in $VmUuid)
        {
            if ($PSCmdlet.ShouldProcess($id, "start"))
            {
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$id/actions/start" -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}

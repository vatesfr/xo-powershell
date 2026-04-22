# SPDX-License-Identifier: Apache-2.0

function Stop-XoVm
{
    <#
    .SYNOPSIS
        Stop one or more VMs.
    .DESCRIPTION
        Stops the specified VMs. By default, performs a clean shutdown.
        Use -Force to perform a hard shutdown.
    .PARAMETER VmUuid
        The UUID(s) of the VM(s) to stop.
    .PARAMETER Force
        If specified, performs a hard shutdown instead of a clean shutdown.
    .EXAMPLE
        Stop-XoVm -VmUuid "12345678-abcd-1234-abcd-1234567890ab"
        Performs a clean shutdown of the VM with the specified UUID.
    .EXAMPLE
        Get-XoVm -PowerState Running | Stop-XoVm -Force
        Performs a hard shutdown of all running VMs.
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
            "hard_shutdown"
        }
        else
        {
            "clean_shutdown"
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

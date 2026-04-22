# SPDX-License-Identifier: Apache-2.0

function Invoke-XoVmPause
{
    <#
    .SYNOPSIS
        Pause one or more Xen Orchestra VMs.
    .DESCRIPTION
        Freezes CPU execution of the VM without saving RAM state. Use Invoke-XoVmUnpause to resume. Not to be confused with Suspend-XoVm, which writes memory to disk.
    .PARAMETER VmUuid
        The UUID(s) of the VM to act on. Accepts pipeline input by property name.
    .EXAMPLE
        Invoke-XoVmPause -VmUuid "<uuid>"
    .EXAMPLE
        Invoke-XoVmPause -VmUuid "<uuid>" | Wait-XoTask -PassThru
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    [OutputType("XoPowershell.Task")]
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
            if ($PSCmdlet.ShouldProcess($id, "pause"))
            {
                $uri = "$script:XoHost/rest/v0/vms/$id/actions/pause"
                Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}


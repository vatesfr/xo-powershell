# SPDX-License-Identifier: Apache-2.0

function Invoke-XoVmUnpause
{
    <#
    .SYNOPSIS
        Unpause one or more Xen Orchestra VMs.
    .DESCRIPTION
        Resumes CPU execution of a paused VM (previously paused with Invoke-XoVmPause).
    .PARAMETER VmUuid
        The UUID(s) of the VM to act on. Accepts pipeline input by property name.
    .EXAMPLE
        Invoke-XoVmUnpause -VmUuid "<uuid>"
    .EXAMPLE
        Invoke-XoVmUnpause -VmUuid "<uuid>" | Wait-XoTask -PassThru
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
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
            if ($PSCmdlet.ShouldProcess($id, "unpause"))
            {
                $uri = "$script:XoHost/rest/v0/vms/$id/actions/unpause"
                Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}


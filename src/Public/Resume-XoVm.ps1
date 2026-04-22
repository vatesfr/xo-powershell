# SPDX-License-Identifier: Apache-2.0

function Resume-XoVm
{
    <#
    .SYNOPSIS
        Resume one or more Xen Orchestra VMs.
    .DESCRIPTION
        Resumes a suspended VM, restoring its memory from disk and returning it to the Running state.
    .PARAMETER VmUuid
        The UUID(s) of the VM to act on. Accepts pipeline input by property name.
    .EXAMPLE
        Resume-XoVm -VmUuid "<uuid>"
    .EXAMPLE
        Resume-XoVm -VmUuid "<uuid>" | Wait-XoTask -PassThru
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
            if ($PSCmdlet.ShouldProcess($id, "resume"))
            {
                $uri = "$script:XoHost/rest/v0/vms/$id/actions/resume"
                Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}


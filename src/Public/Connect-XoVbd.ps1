# SPDX-License-Identifier: Apache-2.0

function Connect-XoVbd
{
    <#
    .SYNOPSIS
        Plug one or more Xen Orchestra VBDs.
    .DESCRIPTION
        Plugs the VBD into its VM so the guest can see the backing VDI (hot-plug if the VM is running). Returns a task.
    .PARAMETER VbdUuid
        The UUID(s) of the VBD to act on. Accepts pipeline input by property name.
    .EXAMPLE
        Connect-XoVbd -VbdUuid "<uuid>"
    .EXAMPLE
        Connect-XoVbd -VbdUuid "<uuid>" | Wait-XoTask -PassThru
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    [OutputType("XoPowershell.Task")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string[]]$VbdUuid
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
        foreach ($id in $VbdUuid)
        {
            if ($PSCmdlet.ShouldProcess($id, "connect"))
            {
                $uri = "$script:XoHost/rest/v0/vbds/$id/actions/connect"
                Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}


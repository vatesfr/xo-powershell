# SPDX-License-Identifier: Apache-2.0

function Disconnect-XoVbd
{
    <#
    .SYNOPSIS
        Unplug one or more Xen Orchestra VBDs.
    .DESCRIPTION
        Unplugs the VBD from its VM. Any guest I/O to the disk is cut off.
    .PARAMETER VbdUuid
        The UUID(s) of the VBD to act on. Accepts pipeline input by property name.
    .EXAMPLE
        Disconnect-XoVbd -VbdUuid "<uuid>"
    .EXAMPLE
        Disconnect-XoVbd -VbdUuid "<uuid>" | Wait-XoTask -PassThru
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
            if ($PSCmdlet.ShouldProcess($id, "disconnect"))
            {
                $uri = "$script:XoHost/rest/v0/vbds/$id/actions/disconnect"
                Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}


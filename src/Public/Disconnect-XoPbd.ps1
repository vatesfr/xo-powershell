# SPDX-License-Identifier: Apache-2.0

function Disconnect-XoPbd
{
    <#
    .SYNOPSIS
        Unplug one or more Xen Orchestra PBDs.
    .DESCRIPTION
        Detaches the PBD from its host, taking the SR offline on that host. All VMs/VDIs using the SR from this host must be detached or migrated first.
    .PARAMETER PbdUuid
        The UUID(s) of the PBD to act on. Accepts pipeline input by property name.
    .EXAMPLE
        Disconnect-XoPbd -PbdUuid "<uuid>"
    .EXAMPLE
        Disconnect-XoPbd -PbdUuid "<uuid>" | Wait-XoTask -PassThru
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    [OutputType("XoPowershell.Task")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string[]]$PbdUuid
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
        foreach ($id in $PbdUuid)
        {
            if ($PSCmdlet.ShouldProcess($id, "unplug"))
            {
                $uri = "$script:XoHost/rest/v0/pbds/$id/actions/unplug"
                Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}


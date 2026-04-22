# SPDX-License-Identifier: Apache-2.0

function Disable-XoHost
{
    <#
    .SYNOPSIS
        Disable one or more Xen Orchestra hosts.
    .DESCRIPTION
        Marks the host as disabled so the pool scheduler stops placing new VMs on it. Existing VMs keep running until migrated or shut down.
    .PARAMETER HostUuid
        The UUID(s) of the host to act on. Accepts pipeline input by property name.
    .EXAMPLE
        Disable-XoHost -HostUuid "<uuid>"
    .EXAMPLE
        Disable-XoHost -HostUuid "<uuid>" | Wait-XoTask -PassThru
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    [OutputType("XoPowershell.Task")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string[]]$HostUuid
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
        foreach ($id in $HostUuid)
        {
            if ($PSCmdlet.ShouldProcess($id, "disable"))
            {
                $uri = "$script:XoHost/rest/v0/hosts/$id/actions/disable"
                Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}


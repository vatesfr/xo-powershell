# SPDX-License-Identifier: Apache-2.0

function Enable-XoHost
{
    <#
    .SYNOPSIS
        Enable one or more Xen Orchestra hosts.
    .DESCRIPTION
        Marks the host as enabled so the pool scheduler will place new VMs on it.
    .PARAMETER HostUuid
        The UUID(s) of the host to act on. Accepts pipeline input by property name.
    .EXAMPLE
        Enable-XoHost -HostUuid "<uuid>"
    .EXAMPLE
        Enable-XoHost -HostUuid "<uuid>" | Wait-XoTask -PassThru
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
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
            if ($PSCmdlet.ShouldProcess($id, "enable"))
            {
                $uri = "$script:XoHost/rest/v0/hosts/$id/actions/enable"
                Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}


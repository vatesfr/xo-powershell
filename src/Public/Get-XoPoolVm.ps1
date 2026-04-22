# SPDX-License-Identifier: Apache-2.0

function Get-XoPoolVm
{
    <#
    .SYNOPSIS
        Get VMs scoped to a specific pool.
    .DESCRIPTION
        Returns the VMs that belong to the specified pool(s). The XO REST API does not expose a dedicated GET /pools/{id}/vms endpoint (only POST for imports), so this cmdlet delegates to Get-XoVm with a $pool filter. Accepts one or more pool UUIDs and pipeline input by property name.
    .PARAMETER PoolUuid
        The UUID(s) of the pool whose VMs should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoPoolVm -PoolUuid "b7569d99-30f8-178a-7d94-801de3e29b5b"
    .EXAMPLE
        Get-XoPool | Get-XoPoolVm
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Vm")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$PoolUuid
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
        foreach ($id in $PoolUuid)
        {
            Get-XoVm -PoolUuid $id
        }
    }
}

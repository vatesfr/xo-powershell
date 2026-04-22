# SPDX-License-Identifier: Apache-2.0

function New-XoBondedNetwork
{
    <#
    .SYNOPSIS
        Create a new bonded network on a Xen Orchestra pool.
    .DESCRIPTION
        Creates a bonded network from a set of PIFs on the specified pool. Thin wrapper
        around the internal Invoke-XoPoolAction -Action create_bonded_network helper.
        Returns a task object that can be passed to Wait-XoTask to monitor completion.
    .PARAMETER PoolUuid
        The UUID of the pool to create the bonded network on.
    .PARAMETER Name
        The name of the new bonded network.
    .PARAMETER PifUuid
        The UUIDs of the PIFs to bond together.
    .PARAMETER BondMode
        The bonding mode. Typical values: balance-slb, active-backup, lacp.
    .PARAMETER Description
        Optional description of the new bonded network.
    .PARAMETER AdditionalParameters
        Optional hashtable of extra body parameters to merge into the
        create_bonded_network action payload. Values here override the dedicated
        parameters above.
    .EXAMPLE
        New-XoBondedNetwork -PoolUuid $pool.PoolUuid -Name "bond0" -PifUuid $p1,$p2 -BondMode lacp
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    [OutputType("XoPowershell.Task")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string]$PoolUuid,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [Alias("PifIds")]
        [string[]]$PifUuid,

        [Parameter(Mandatory)]
        [ValidateSet("balance-slb", "active-backup", "lacp")]
        [string]$BondMode,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [hashtable]$AdditionalParameters
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
        if (-not $PSCmdlet.ShouldProcess($Name, "create bonded network on pool $PoolUuid"))
        {
            return
        }

        $params = @{
            name     = $Name
            pifIds   = @($PifUuid)
            bondMode = $BondMode
        }

        if ($PSBoundParameters.ContainsKey("Description"))
        {
            $params["description"] = $Description
        }

        if ($AdditionalParameters)
        {
            foreach ($key in $AdditionalParameters.Keys)
            {
                $params[$key] = $AdditionalParameters[$key]
            }
        }

        Invoke-XoPoolAction -PoolUuid $PoolUuid -Action "create_bonded_network" -ActionParameters $params
    }
}

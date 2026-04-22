# SPDX-License-Identifier: Apache-2.0

function New-XoNetwork
{
    <#
    .SYNOPSIS
        Create a new network on a Xen Orchestra pool.
    .DESCRIPTION
        Creates a regular network on the specified pool. Thin wrapper around the
        internal Invoke-XoPoolAction -Action create_network helper. Returns a task
        object that can be passed to Wait-XoTask to monitor completion.
    .PARAMETER PoolUuid
        The UUID of the pool to create the network on.
    .PARAMETER Name
        The name of the new network.
    .PARAMETER Description
        Optional description of the new network.
    .PARAMETER PifUuid
        Optional UUID of the PIF to attach the network to.
    .PARAMETER Vlan
        Optional VLAN id for the new network. Use 0 for untagged.
    .PARAMETER AdditionalParameters
        Optional hashtable of extra body parameters to merge into the create_network
        action payload. Values here override the dedicated parameters above.
    .EXAMPLE
        New-XoNetwork -PoolUuid $pool.PoolUuid -Name "frontend" -PifUuid $pif.PifUuid -Vlan 100
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

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string]$PifUuid,

        [Parameter()]
        [ValidateRange(0, 4094)]
        [int]$Vlan,

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
        if (-not $PSCmdlet.ShouldProcess($Name, "create network on pool $PoolUuid"))
        {
            return
        }

        $params = @{
            name = $Name
        }

        if ($PSBoundParameters.ContainsKey("Description"))
        {
            $params["description"] = $Description
        }
        if ($PSBoundParameters.ContainsKey("PifUuid"))
        {
            $params["pif"] = $PifUuid
        }
        if ($PSBoundParameters.ContainsKey("Vlan"))
        {
            $params["vlan"] = $Vlan
        }

        if ($AdditionalParameters)
        {
            foreach ($key in $AdditionalParameters.Keys)
            {
                $params[$key] = $AdditionalParameters[$key]
            }
        }

        Invoke-XoPoolAction -PoolUuid $PoolUuid -Action "create_network" -ActionParameters $params
    }
}

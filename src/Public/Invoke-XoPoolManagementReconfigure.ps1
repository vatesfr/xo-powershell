# SPDX-License-Identifier: Apache-2.0

function Invoke-XoPoolManagementReconfigure
{
    <#
    .SYNOPSIS
        Reconfigure the management network of a Xen Orchestra pool.
    .DESCRIPTION
        Points the pool's management interface at a different network. Thin wrapper
        around the internal Invoke-XoPoolAction -Action management_reconfigure helper.
        Returns a task object that can be passed to Wait-XoTask to monitor completion.
    .PARAMETER PoolUuid
        The UUID of the pool whose management network is being reconfigured.
    .PARAMETER NetworkUuid
        The UUID of the network to use as the new management network.
    .PARAMETER AdditionalParameters
        Optional hashtable of extra body parameters to merge into the
        management_reconfigure action payload. Values here override NetworkUuid.
    .EXAMPLE
        Invoke-XoPoolManagementReconfigure -PoolUuid $pool.PoolUuid -NetworkUuid $net.NetworkUuid
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    [OutputType("XoPowershell.Task")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string]$PoolUuid,

        [Parameter(Mandatory, Position = 1)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string]$NetworkUuid,

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
        if (-not $PSCmdlet.ShouldProcess($PoolUuid, "reconfigure management network to $NetworkUuid"))
        {
            return
        }

        $params = @{
            network = $NetworkUuid
        }

        if ($AdditionalParameters)
        {
            foreach ($key in $AdditionalParameters.Keys)
            {
                $params[$key] = $AdditionalParameters[$key]
            }
        }

        Invoke-XoPoolAction -PoolUuid $PoolUuid -Action "management_reconfigure" -ActionParameters $params
    }
}

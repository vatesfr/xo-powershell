# SPDX-License-Identifier: Apache-2.0

function New-XoInternalNetwork
{
    <#
    .SYNOPSIS
        Create a new internal network on a Xen Orchestra pool.
    .DESCRIPTION
        Creates an internal (host-local, no external uplink) network on the specified
        pool. Thin wrapper around the internal Invoke-XoPoolAction -Action
        create_internal_network helper. Returns a task object that can be passed to
        Wait-XoTask to monitor completion.
    .PARAMETER PoolUuid
        The UUID of the pool to create the internal network on.
    .PARAMETER Name
        The name of the new internal network.
    .PARAMETER Description
        Optional description of the new internal network.
    .PARAMETER AdditionalParameters
        Optional hashtable of extra body parameters to merge into the
        create_internal_network action payload. Values here override the dedicated
        parameters above.
    .EXAMPLE
        New-XoInternalNetwork -PoolUuid $pool.PoolUuid -Name "private-lab"
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
        if (-not $PSCmdlet.ShouldProcess($Name, "create internal network on pool $PoolUuid"))
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

        if ($AdditionalParameters)
        {
            foreach ($key in $AdditionalParameters.Keys)
            {
                $params[$key] = $AdditionalParameters[$key]
            }
        }

        Invoke-XoPoolAction -PoolUuid $PoolUuid -Action "create_internal_network" -ActionParameters $params
    }
}

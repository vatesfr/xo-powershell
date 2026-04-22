# SPDX-License-Identifier: Apache-2.0

function Stop-XoPool
{
    <#
    .SYNOPSIS
        Stop a running pool.
    .DESCRIPTION
        Stop the specified pools. Currently only supports emergency shutdown.
    .PARAMETER PoolUuid
        The UUID(s) of the pools(s) to stop.
    .PARAMETER Force
        Perform an emergency shutdown.
    .EXAMPLE
        Stop-XoPool -PoolUuid "12345678-abcd-1234-abcd-1234567890ab" -Force
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$PoolUuid,

        [Parameter(Mandatory)]
        [switch]$Force
    )

    process
    {
        # Note: "Stop" is quite different from "emergency shutdown", thus the "-Force" parameter being mandatory for now.
        # Added splatting to make it more flexible in the future.
        $params = @{}
        foreach ($id in $PoolUuid)
        {
            $params["PoolUuid"] = $id
            if ($PSBoundParameters.ContainsKey('Force'))
            {
                $params["Action"] = "emergency_shutdown"
            }
            if ($PSCmdlet.ShouldProcess($id, "Emergency shutdown"))
            {
                Invoke-XoPoolAction @params
            }
        }
    }
}

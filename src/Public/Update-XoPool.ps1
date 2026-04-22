# SPDX-License-Identifier: Apache-2.0

function Update-XoPool
{
    <#
    .SYNOPSIS
        Update a running pool.
    .DESCRIPTION
        Update the specified pools using a rolling pool update.
    .PARAMETER PoolUuid
        The UUID(s) of the pools(s) to update.
    .EXAMPLE
        Update-XoPool -PoolUuid "12345678-abcd-1234-abcd-1234567890ab"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$PoolUuid
    )

    process
    {
        foreach ($id in $PoolUuid)
        {
            if ($PSCmdlet.ShouldProcess($id, "Rolling pool update"))
            {
                Invoke-XoPoolAction -PoolUuid $id -Action "rolling_update"
            }
        }
    }
}

# SPDX-License-Identifier: Apache-2.0

function Remove-XoNetwork
{
    <#
    .SYNOPSIS
        Delete one or more Xen Orchestra networks.
    .DESCRIPTION
        Issues DELETE /networks/{id}. Accepts multiple IDs and pipeline input by property name.
    .PARAMETER NetworkUuid
        The ID(s) of the network(s) to delete.
    .EXAMPLE
        Remove-XoNetwork -NetworkUuid "<id>"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string[]]$NetworkUuid
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
        foreach ($id in $NetworkUuid)
        {
            if ($PSCmdlet.ShouldProcess($id, "delete network"))
            {
                $uri = "$script:XoHost/rest/v0/networks/$id"
                Invoke-RestMethod -Uri $uri -Method Delete @script:XoRestParameters
            }
        }
    }
}

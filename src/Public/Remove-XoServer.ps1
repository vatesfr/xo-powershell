# SPDX-License-Identifier: Apache-2.0

function Remove-XoServer
{
    <#
    .SYNOPSIS
        Delete one or more Xen Orchestra XO servers.
    .DESCRIPTION
        Issues DELETE /servers/{id}. Accepts multiple IDs and pipeline input by property name.
    .PARAMETER ServerUuid
        The ID(s) of the XO server(s) to delete.
    .EXAMPLE
        Remove-XoServer -ServerUuid "<id>"
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ServerUuid
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
        foreach ($id in $ServerUuid)
        {
            if ($PSCmdlet.ShouldProcess($id, "delete XO server"))
            {
                $uri = "$script:XoHost/rest/v0/servers/$id"
                Invoke-RestMethod -Uri $uri -Method Delete @script:XoRestParameters
            }
        }
    }
}

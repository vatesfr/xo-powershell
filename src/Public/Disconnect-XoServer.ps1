# SPDX-License-Identifier: Apache-2.0

function Disconnect-XoServer
{
    <#
    .SYNOPSIS
        Disconnect one or more Xen Orchestra XO servers.
    .DESCRIPTION
        Drops the XAPI connection for the registered XO server. The server stays registered but its pool stops syncing until reconnected.
    .PARAMETER ServerUuid
        The UUID(s) of the XO server to act on. Accepts pipeline input by property name.
    .EXAMPLE
        Disconnect-XoServer -ServerUuid "<uuid>"
    .EXAMPLE
        Disconnect-XoServer -ServerUuid "<uuid>" | Wait-XoTask -PassThru
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    [OutputType("XoPowershell.Task")]
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
            if ($PSCmdlet.ShouldProcess($id, "disconnect"))
            {
                $uri = "$script:XoHost/rest/v0/servers/$id/actions/disconnect"
                Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}


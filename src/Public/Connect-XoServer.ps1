# SPDX-License-Identifier: Apache-2.0

function Connect-XoServer
{
    <#
    .SYNOPSIS
        Connect one or more Xen Orchestra XO servers.
    .DESCRIPTION
        Establishes the XAPI connection for the registered XO server. Returns a task object.
    .PARAMETER ServerUuid
        The UUID(s) of the XO server to act on. Accepts pipeline input by property name.
    .EXAMPLE
        Connect-XoServer -ServerUuid "<uuid>"
    .EXAMPLE
        Connect-XoServer -ServerUuid "<uuid>" | Wait-XoTask -PassThru
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
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
            if ($PSCmdlet.ShouldProcess($id, "connect"))
            {
                $uri = "$script:XoHost/rest/v0/servers/$id/actions/connect"
                Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}


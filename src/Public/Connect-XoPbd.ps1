# SPDX-License-Identifier: Apache-2.0

function Connect-XoPbd
{
    <#
    .SYNOPSIS
        Plug one or more Xen Orchestra PBDs.
    .DESCRIPTION
        Attaches the PBD to its host, making the underlying SR available. Returns a task that can be passed to Wait-XoTask.
    .PARAMETER PbdUuid
        The UUID(s) of the PBD to act on. Accepts pipeline input by property name.
    .EXAMPLE
        Connect-XoPbd -PbdUuid "<uuid>"
    .EXAMPLE
        Connect-XoPbd -PbdUuid "<uuid>" | Wait-XoTask -PassThru
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    [OutputType("XoPowershell.Task")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string[]]$PbdUuid
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
        foreach ($id in $PbdUuid)
        {
            if ($PSCmdlet.ShouldProcess($id, "plug"))
            {
                $uri = "$script:XoHost/rest/v0/pbds/$id/actions/plug"
                Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}


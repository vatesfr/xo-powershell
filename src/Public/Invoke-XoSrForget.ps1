# SPDX-License-Identifier: Apache-2.0

function Invoke-XoSrForget
{
    <#
    .SYNOPSIS
        Forget one or more Xen Orchestra SRs.
    .DESCRIPTION
        Detaches the SR from the pool without destroying the underlying storage (the data and VDIs remain on the remote; they can be re-introduced later).
    .PARAMETER SrUuid
        The UUID(s) of the SR to act on. Accepts pipeline input by property name.
    .EXAMPLE
        Invoke-XoSrForget -SrUuid "<uuid>"
    .EXAMPLE
        Invoke-XoSrForget -SrUuid "<uuid>" | Wait-XoTask -PassThru
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    [OutputType("XoPowershell.Task")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string[]]$SrUuid
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
        foreach ($id in $SrUuid)
        {
            if ($PSCmdlet.ShouldProcess($id, "forget"))
            {
                $uri = "$script:XoHost/rest/v0/srs/$id/actions/forget"
                Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}


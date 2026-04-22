# SPDX-License-Identifier: Apache-2.0

function Invoke-XoSrReclaimSpace
{
    <#
    .SYNOPSIS
        Reclaim space on one or more Xen Orchestra SRs.
    .DESCRIPTION
        Triggers space reclamation (TRIM/UNMAP) on the SR. Useful on thin-provisioned storage to return freed blocks.
    .PARAMETER SrUuid
        The UUID(s) of the SR to act on. Accepts pipeline input by property name.
    .EXAMPLE
        Invoke-XoSrReclaimSpace -SrUuid "<uuid>"
    .EXAMPLE
        Invoke-XoSrReclaimSpace -SrUuid "<uuid>" | Wait-XoTask -PassThru
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
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
            if ($PSCmdlet.ShouldProcess($id, "reclaim space"))
            {
                $uri = "$script:XoHost/rest/v0/srs/$id/actions/reclaim_space"
                Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}


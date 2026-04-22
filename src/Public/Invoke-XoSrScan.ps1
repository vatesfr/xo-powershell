# SPDX-License-Identifier: Apache-2.0

function Invoke-XoSrScan
{
    <#
    .SYNOPSIS
        Rescan one or more Xen Orchestra SRs.
    .DESCRIPTION
        Forces XAPI to rescan the SR. Reconciles newly appeared or disappeared VDIs with the database.
    .PARAMETER SrUuid
        The UUID(s) of the SR to act on. Accepts pipeline input by property name.
    .EXAMPLE
        Invoke-XoSrScan -SrUuid "<uuid>"
    .EXAMPLE
        Invoke-XoSrScan -SrUuid "<uuid>" | Wait-XoTask -PassThru
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
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
            if ($PSCmdlet.ShouldProcess($id, "scan"))
            {
                $uri = "$script:XoHost/rest/v0/srs/$id/actions/scan"
                Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}


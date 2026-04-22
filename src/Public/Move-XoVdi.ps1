# SPDX-License-Identifier: Apache-2.0

function Move-XoVdi
{
    <#
    .SYNOPSIS
        Migrate a Xen Orchestra VDI to another storage repository.
    .DESCRIPTION
        Triggers a live VDI migration to a different SR. The destination SR UUID must be provided via -Parameters (e.g. ``@{ sr_id = <uuid> }``); see the XO REST docs at /rest/v0/docs/#/vdis/MigrateVdi for the full schema. Returns a task object.
    .PARAMETER VdiUuid
        The UUID of the VDI to act on.
    .PARAMETER Parameters
        Hashtable of action body parameters. See the linked XO REST documentation for the expected fields.
    .EXAMPLE
        Move-XoVdi -VdiUuid "<uuid>" -Parameters @{ }
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    [OutputType("XoPowershell.Task")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string]$VdiUuid,

        [Parameter()]
        [hashtable]$Parameters
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
        if ($PSCmdlet.ShouldProcess($VdiUuid, "migrate"))
        {
            $uri = "$script:XoHost/rest/v0/vdis/$VdiUuid/actions/migrate"
            $body = if ($Parameters) { [System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json $Parameters -Depth 99)) } else { [byte[]]@() }
            Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters -ContentType "application/json" -Body $body | ForEach-Object {
                ConvertFrom-XoTaskHref $_
            }
        }
    }
}


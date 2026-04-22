# SPDX-License-Identifier: Apache-2.0

function Move-XoVm
{
    <#
    .SYNOPSIS
        Live-migrate a Xen Orchestra VM to another host.
    .DESCRIPTION
        Triggers a live VM migration. The destination host UUID (and optionally migration network / storage) must be provided via -Parameters. See /rest/v0/docs/#/vms/MigrateVm for the expected body. Returns a task object.
    .PARAMETER VmUuid
        The UUID of the VM to act on.
    .PARAMETER Parameters
        Hashtable of action body parameters. See the linked XO REST documentation for the expected fields.
    .EXAMPLE
        Move-XoVm -VmUuid "<uuid>" -Parameters @{ }
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    [OutputType("XoPowershell.Task")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string]$VmUuid,

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
        if ($PSCmdlet.ShouldProcess($VmUuid, "migrate"))
        {
            $uri = "$script:XoHost/rest/v0/vms/$VmUuid/actions/migrate"
            $body = if ($Parameters) { [System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json $Parameters -Depth 99)) } else { [byte[]]@() }
            Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters -ContentType "application/json" -Body $body | ForEach-Object {
                ConvertFrom-XoTaskHref $_
            }
        }
    }
}


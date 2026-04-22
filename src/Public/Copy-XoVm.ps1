# SPDX-License-Identifier: Apache-2.0

function Copy-XoVm
{
    <#
    .SYNOPSIS
        Clone a Xen Orchestra VM.
    .DESCRIPTION
        Clones the specified VM. Use -Parameters to pass optional clone options (e.g. ``@{ name = "copy"; full_copy = $true }``). Returns a task object.
    .PARAMETER VmUuid
        The UUID of the VM to act on.
    .PARAMETER Parameters
        Hashtable of action body parameters. See the linked XO REST documentation for the expected fields.
    .EXAMPLE
        Copy-XoVm -VmUuid "<uuid>" -Parameters @{ }
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
        if ($PSCmdlet.ShouldProcess($VmUuid, "clone"))
        {
            $uri = "$script:XoHost/rest/v0/vms/$VmUuid/actions/clone"
            $body = if ($Parameters) { [System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json $Parameters -Depth 99)) } else { [byte[]]@() }
            Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters -ContentType "application/json" -Body $body | ForEach-Object {
                ConvertFrom-XoTaskHref $_
            }
        }
    }
}


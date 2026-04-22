# SPDX-License-Identifier: Apache-2.0

function New-XoVbd
{
    <#
    .SYNOPSIS
        Create a new Xen Orchestra VBD linking a VDI to a VM.
    .DESCRIPTION
        Calls POST /vbds to attach a VDI to a VM. The resulting VBD controls whether the VM boots from the VDI and whether it is read-only or read/write.
    .PARAMETER VmUuid
        The UUID of the VM to attach the VDI to.
    .PARAMETER VdiUuid
        The UUID of the VDI to attach.
    .PARAMETER Bootable
        Mark the VBD as bootable.
    .PARAMETER Mode
        Access mode: 'RW' (read/write, default) or 'RO' (read-only).
    .EXAMPLE
        New-XoVbd -VmUuid "<vm>" -VdiUuid "<vdi>" -Bootable
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    [OutputType("XoPowershell.Vbd")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string]$VmUuid,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string]$VdiUuid,

        [Parameter()]
        [switch]$Bootable,

        [Parameter()]
        [ValidateSet("RW", "RO")]
        [string]$Mode = "RW"
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
        if (-not $PSCmdlet.ShouldProcess("VM $VmUuid", "attach VDI $VdiUuid"))
        {
            return
        }

        $body = @{
            VM       = $VmUuid
            VDI      = $VdiUuid
            bootable = [bool]$Bootable
            mode     = $Mode
        }
        $bodyJson  = ConvertTo-Json -InputObject $body -Depth 5 -Compress
        $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyJson)

        $uri = "$script:XoHost/rest/v0/vbds"
        Invoke-RestMethod -Uri $uri -Method Post @script:XoRestParameters -ContentType "application/json" -Body $bodyBytes
    }
}

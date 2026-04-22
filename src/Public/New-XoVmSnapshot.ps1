# SPDX-License-Identifier: Apache-2.0

function New-XoVmSnapshot
{
    <#
    .SYNOPSIS
        Create a snapshot of one or more VMs.
    .DESCRIPTION
        Creates a snapshot of the specified VMs. Optionally, you can specify a custom name
        for the snapshot.
    .PARAMETER VmUuid
        The UUID(s) of the VM(s) to snapshot.
    .PARAMETER SnapshotName
        The name to give to the snapshot. If not specified, a default name will be used.
    .PARAMETER NameLabel
        Alias for SnapshotName. The name to give to the snapshot.
    .EXAMPLE
        New-XoVmSnapshot -VmUuid "12345678-abcd-1234-abcd-1234567890ab"
        Creates a snapshot of the VM with the specified UUID.
    .EXAMPLE
        New-XoVmSnapshot -VmUuid "12345678-abcd-1234-abcd-1234567890ab" -SnapshotName "Before Update"
        Creates a snapshot named "Before Update" of the VM with the specified UUID.
    .EXAMPLE
        New-XoVmSnapshot -VmUuid "12345678-abcd-1234-abcd-1234567890ab" -NameLabel "Before Update"
        Creates a snapshot named "Before Update" of the VM with the specified UUID.
    .EXAMPLE
        Get-XoVm -PowerState Running | New-XoVmSnapshot -SnapshotName "Backup $(Get-Date -Format 'yyyy-MM-dd')"
        Creates a dated snapshot of all running VMs.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$VmUuid,

        [Parameter()]
        [Alias("NameLabel")]
        [string]$SnapshotName
    )

    begin
    {
        $params = Remove-XoEmptyValues @{
            name_label = $SnapshotName
        }
    }

    process
    {
        foreach ($id in $VmUuid)
        {
            if ($PSCmdlet.ShouldProcess($id, "snapshot"))
            {
                Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vms/$id/actions/snapshot" -Method Post @script:XoRestParameters -Body $params | ForEach-Object {
                    ConvertFrom-XoTaskHref $_
                }
            }
        }
    }
}

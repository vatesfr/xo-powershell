# SPDX-License-Identifier: Apache-2.0

function Get-XoVmDashboard
{
    <#
    .SYNOPSIS
        Get dashboard summary scoped to a specific VM.
    .DESCRIPTION
        Retrieves dashboard summary attached to the specified Xen Orchestra VM. Accepts one or more VM UUIDs; each is queried independently and the combined results are returned.
    .PARAMETER VmUuid
        The UUID(s) of the VM whose dashboard summary should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoVmDashboard -VmUuid "613f541c-4bed-fc77-7ca8-2db6b68f079c"
    .EXAMPLE
        Get-XoVm | Get-XoVmDashboard
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Dashboard")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$VmUuid
    )

    begin
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }

        $params = @{}

    }

    process
    {
        foreach ($id in $VmUuid)
        {
            $uri = "$script:XoHost/rest/v0/vms/$id/dashboard"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoDashboardObject
        }
    }
}


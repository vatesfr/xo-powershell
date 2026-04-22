# SPDX-License-Identifier: Apache-2.0

function Get-XoVmTemplateVdi
{
    <#
    .SYNOPSIS
        Get virtual disks (VDIs) scoped to a specific VM template.
    .DESCRIPTION
        Retrieves virtual disks (VDIs) attached to the specified Xen Orchestra VM template. Accepts one or more VM template UUIDs; each is queried independently and the combined results are returned.
    .PARAMETER VmTemplateUuid
        The UUID(s) of the VM template whose virtual disks (VDIs) should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoVmTemplateVdi -VmTemplateUuid "00000000-0000-0000-0000-000000000000"
    .EXAMPLE
        Get-XoVmTemplate | Get-XoVmTemplateVdi
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Vdi")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$VmTemplateUuid
    )

    begin
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }

        $params = @{}
        $params["fields"] = $script:XO_VDI_FIELDS
    }

    process
    {
        foreach ($id in $VmTemplateUuid)
        {
            $uri = "$script:XoHost/rest/v0/vm-templates/$id/vdis"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoVdiObject
        }
    }
}


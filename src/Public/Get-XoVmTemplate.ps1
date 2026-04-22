# SPDX-License-Identifier: Apache-2.0

function Get-XoVmTemplate
{
    <#
    .SYNOPSIS
        List or query VM templates.
    .DESCRIPTION
        Get Xen Orchestra VM templates by UUID or list all existing VM templates.
    .PARAMETER VmTemplateUuid
        The UUID(s) of the VM template(s) to retrieve.
    .PARAMETER Default
        Only return default VM templates when set.
    .PARAMETER PoolUuid
        UUID of the pool whose templates to retrieve.
    .PARAMETER Filter
        Custom filter expression for the template query.
    .PARAMETER Limit
        Maximum number of VM templates to return.
    .EXAMPLE
        Get-XoVmTemplate -VmTemplateUuid "12345678-abcd-1234-abcd-1234567890ab"
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    [OutputType("XoPowershell.VmTemplate")]
    param (
        # UUIDs of VM templates to query.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "VmTemplateUuid")]
        [ValidatePattern("([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}-?)+")]
        [string[]]$VmTemplateUuid,

        [Parameter(ParameterSetName = "Filter")]
        [switch]$Default,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Filter")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string]$PoolUuid,

        # Filter to apply to the VM template query.
        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        # Maximum number of results to return.
        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit = $script:XoSessionLimit
    )

    begin
    {
        $params = @{
            fields = $script:XO_VM_TEMPLATE_FIELDS
        }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "VmTemplateUuid")
        {
            foreach ($id in $VmTemplateUuid)
            {
                ConvertTo-XoVmTemplateObject (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vm-templates/$id" @script:XoRestParameters -Body $params)
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            Write-Verbose $script:XO_VM_TEMPLATE_FIELDS
            $AllFilters = $Filter

            if ($Default)
            {
                $AllFilters = "$AllFilters isDefaultTemplate?"
            }
            elseif ($PSBoundParameters.ContainsKey("Default"))
            {
                $AllFilters = "$AllFilters !isDefaultTemplate?"
            }

            if ($PoolUuid)
            {
                $AllFilters = "$AllFilters `$pool:$PoolUuid"
            }

            if ($AllFilters)
            {
                $params["filter"] = $AllFilters
            }

            if ($Limit)
            {
                $params["limit"] = $Limit
            }

            # the parentheses forces the resulting array to unpack, don't remove them!
            (Invoke-RestMethod -Uri "$script:XoHost/rest/v0/vm-templates" @script:XoRestParameters -Body $params) | ConvertTo-XoVmTemplateObject
        }
    }
}

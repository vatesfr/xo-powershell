# SPDX-License-Identifier: Apache-2.0

$script:XO_VM_FIELDS = "uuid,name_label,name_description,power_state,addresses,tags,memory,VIFs,snapshots,current_operations,auto_poweron,os_version,startTime,VCPUs_at_startup,CPUs,VCPUs_number,`$VBDs"
$script:XO_VM_TEMPLATE_FIELDS = $script:XO_VM_FIELDS + ",isDefaultTemplate"

function ConvertTo-XoVmObject
{
    <#
    .SYNOPSIS
        Convert a VM object from the API to a PowerShell object.
    .DESCRIPTION
        Convert a VM object from the API to a PowerShell object with proper properties and types.
    .PARAMETER InputObject
        The VM object from the API.
    .EXAMPLE
        ConvertTo-XoVmObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Vm")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [PSObject] $InputObject
    )

    process
    {
        $props = @{
            VmUuid      = $InputObject.uuid
            Name        = $InputObject.name_label
            Description = $InputObject.name_description
            PowerState  = $InputObject.power_state
            OsVersion   = $InputObject.os_version
            Parent      = $InputObject.parent
            HostUuid    = $InputObject.$container
        }

        if ($InputObject.CPUs.number)
        {
            $props["CPUs"] = $InputObject.CPUs.number
        }
        elseif ($InputObject.CPUs.max)
        {
            $props["CPUs"] = $InputObject.CPUs.max
        }
        else
        {
            $props["CPUs"] = $null
        }

        Set-XoObject $InputObject -TypeName XoPowershell.Vm -Properties $props
    }
}

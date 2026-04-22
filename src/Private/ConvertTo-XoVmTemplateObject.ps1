# SPDX-License-Identifier: Apache-2.0

# see ConvertTo-XoVmObject.ps1 for XO_VM_TEMPLATE_FIELDS (which depends on XO_VM_FIELDS)

function ConvertTo-XoVmTemplateObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo VmTemplate object

    .DESCRIPTION
    Convert api object to powershell xo VmTemplate object

    .PARAMETER InputObject
    VM template input object from the API.

    .EXAMPLE
    ConvertTo-XoVmTemplateObject -InputObject $object

    #>
    [Cmdletbinding()]
    [OutputType("XoPowershell.VmTemplate")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            VmTemplateUuid = $InputObject.uuid
            Name           = $InputObject.name_label
            Description    = $InputObject.name_description
            OsVersion      = $InputObject.os_version
            Parent         = $InputObject.parent
            HostUuid       = $InputObject.$container
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

        Set-XoObject $InputObject -TypeName XoPowershell.VmTemplate -Properties $props
    }
}

# SPDX-License-Identifier: Apache-2.0

$script:XO_VM_CONTROLLER_FIELDS = "uuid,name_label,name_description,power_state,$pool,host"

function ConvertTo-XoVmControllerObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo VmController object

    .DESCRIPTION
    Convert an API response to an XO VmController object.

    .PARAMETER InputObject
    VmController input object from the API.

    .EXAMPLE
    ConvertTo-XoVmControllerObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.VmController")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            VmControllerUuid = $InputObject.uuid
            Name = $InputObject.name_label
            Description = $InputObject.name_description
            PowerState = $InputObject.power_state
        }
        Set-XoObject $InputObject -TypeName XoPowershell.VmController -Properties $props
    }
}

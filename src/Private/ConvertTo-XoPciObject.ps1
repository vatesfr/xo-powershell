# SPDX-License-Identifier: Apache-2.0

$script:XO_PCI_FIELDS = "class_name,device_name,id,uuid,pci_id"

function ConvertTo-XoPciObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo Pci object

    .DESCRIPTION
    Convert an API response to an XO Pci object.

    .PARAMETER InputObject
    Pci input object from the API.

    .EXAMPLE
    ConvertTo-XoPciObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Pci")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            PciUuid = $InputObject.uuid
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Pci -Properties $props
    }
}

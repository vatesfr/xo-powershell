# SPDX-License-Identifier: Apache-2.0

$script:XO_VIF_FIELDS = "allowedIpv4Addresses,allowedIpv6Addresses,attached,device,lockingMode,MAC,MTU,txChecksumming,uuid,`$network,`$pool"

function ConvertTo-XoVifObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo Vif object

    .DESCRIPTION
    Convert api object to powershell xo Vif object

    .PARAMETER InputObject
    VIF input object returned from the API.

    .EXAMPLE
    ConvertTo-XoVifObject -InputObject $object

    #>
    [Cmdletbinding()]
    [OutputType("XoPowershell.Vif")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            VifUuid     = $InputObject.uuid
            Name        = $InputObject.name_label
            Description = $InputObject.name_description
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Vif -Properties $props
    }
}

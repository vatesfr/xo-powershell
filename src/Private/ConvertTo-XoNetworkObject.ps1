# SPDX-License-Identifier: Apache-2.0

$script:XO_NETWORK_FIELDS = "automatic,defaultIsLocked,MTU,name_description,name_label,tags,PIFs,VIFs,nbd,uuid,`$pool"

function ConvertTo-XoNetworkObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo network object

    .DESCRIPTION
    Convert api object to powershell xo network object

    .PARAMETER InputObject
    Network input object from the API.

    .EXAMPLE
    ConvertTo-XoNetworkObject -InputObject $object

    #>
    [Cmdletbinding()]
    [OutputType("XoPowershell.Network")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            NetworkUuid = $InputObject.uuid
            Name        = $InputObject.name_label
            Description = $InputObject.name_description
            PifUuid     = $InputObject.PIFs
            VifUuid     = $InputObject.VIFs
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Network -Properties $props
    }
}

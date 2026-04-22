# SPDX-License-Identifier: Apache-2.0

$script:XO_PROXY_FIELDS = "id,name,vmUuid,url,version"

function ConvertTo-XoProxyObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo Proxy object

    .DESCRIPTION
    Convert an API response to an XO Proxy object.

    .PARAMETER InputObject
    Proxy input object from the API.

    .EXAMPLE
    ConvertTo-XoProxyObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Proxy")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            ProxyId = $InputObject.id
            Name = $InputObject.name
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Proxy -Properties $props
    }
}

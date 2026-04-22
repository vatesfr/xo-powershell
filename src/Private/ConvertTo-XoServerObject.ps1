# SPDX-License-Identifier: Apache-2.0

$script:XO_SERVER_FIELDS = "id,host,label,address,version,status,enabled,error,username,readOnly,allowUnauthorized"

function ConvertTo-XoServerObject
{
    <#
    .SYNOPSIS
        Convert a server object from the API to a PowerShell object.
    .DESCRIPTION
        Convert a server object from the API to a PowerShell object with proper properties.
    .PARAMETER InputObject
        The server object from the API.
    .EXAMPLE
        ConvertTo-XoServerObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Server")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        $InputObject
    )

    process
    {
        $props = @{
            ServerUuid        = $InputObject.id  # API returns 'id' field, not 'uuid' for servers
            Name              = $InputObject.label
            NameHost          = $InputObject.host
            Address           = $InputObject.address
            Status            = $InputObject.status
            Version           = $InputObject.version
            Enabled           = $InputObject.enabled
            ReadOnly          = $InputObject.readOnly
            Username          = $InputObject.username
            Error             = $InputObject.error
            AllowUnauthorized = $InputObject.allowUnauthorized
        }

        Set-XoObject $InputObject -TypeName XoPowershell.Server -Properties $props
    }
}

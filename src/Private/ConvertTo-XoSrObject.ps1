# SPDX-License-Identifier: Apache-2.0

$script:XO_SR_FIELDS = "name_label,uuid,SR_type,content_type,allocationStrategy,size,physical_usage,usage,shared"

function ConvertTo-XoSrObject
{
    <#
    .SYNOPSIS
        Convert a storage repository object from the API to a PowerShell object.
    .DESCRIPTION
        Convert a storage repository object from the API to a PowerShell object with proper properties and types.
    .PARAMETER InputObject
        The storage repository object from the API.
    .EXAMPLE
        ConvertTo-XoSrObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Sr")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        $InputObject
    )

    process
    {
        $props = @{
            SrUuid            = $InputObject.uuid
            Name              = $InputObject.name_label
            Type              = $InputObject.SR_type
            ContentType       = $InputObject.content_type
            SrSize            = Format-XoSize $InputObject.size
            UsageSize         = Format-XoSize $InputObject.usage
            PhysicalUsageSize = Format-XoSize $InputObject.physical_usage
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Sr -Properties $props
    }
}

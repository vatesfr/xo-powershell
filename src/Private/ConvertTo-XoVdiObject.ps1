# SPDX-License-Identifier: Apache-2.0

$script:XO_VDI_FIELDS = "name_label,uuid,content_type,size,usage,physical_usage,`$SR,sr_usage"

function ConvertTo-XoVdiObject
{
    <#
    .SYNOPSIS
        Convert a VDI object from the API to a PowerShell object.
    .DESCRIPTION
        Convert a VDI object from the API to a PowerShell object with proper properties and types.
    .PARAMETER InputObject
        The VDI object from the API.
    .EXAMPLE
        ConvertTo-XoVdiObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Vdi")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [PSObject] $InputObject
    )


    process
    {
        $props = @{
            PSTypeName    = "XoPowershell.Vdi"
            VdiUuid       = $InputObject.uuid
            Name          = $InputObject.name_label
            ContentType   = $InputObject.content_type
            Size          = $InputObject.size
            Usage         = $InputObject.usage
            PhysicalUsage = $InputObject.physical_usage
            SrUuid        = $InputObject.sr_uuid
            SrUsage       = $InputObject.sr_usage
        }

        [PSCustomObject]$props
    }
}

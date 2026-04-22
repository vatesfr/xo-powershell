# SPDX-License-Identifier: Apache-2.0

$script:XO_SM_FIELDS = "uuid,name_label,name_description,SM_type,vendor,version"

function ConvertTo-XoSmObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo Sm object

    .DESCRIPTION
    Convert an API response to an XO Sm object.

    .PARAMETER InputObject
    Sm input object from the API.

    .EXAMPLE
    ConvertTo-XoSmObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Sm")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            SmUuid = $InputObject.uuid
            Name = $InputObject.name_label
            Description = $InputObject.name_description
            Type = $InputObject.SM_type
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Sm -Properties $props
    }
}

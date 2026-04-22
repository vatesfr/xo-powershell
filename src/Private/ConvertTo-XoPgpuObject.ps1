# SPDX-License-Identifier: Apache-2.0

$script:XO_PGPU_FIELDS = "id,uuid,dom0Access,gpuGroup,host"

function ConvertTo-XoPgpuObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo Pgpu object

    .DESCRIPTION
    Convert an API response to an XO Pgpu object.

    .PARAMETER InputObject
    Pgpu input object from the API.

    .EXAMPLE
    ConvertTo-XoPgpuObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Pgpu")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            PgpuUuid = $InputObject.uuid
        }
        Set-XoObject $InputObject -TypeName XoPowershell.Pgpu -Properties $props
    }
}

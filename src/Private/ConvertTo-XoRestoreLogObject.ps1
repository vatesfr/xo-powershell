# SPDX-License-Identifier: Apache-2.0

$script:XO_RESTORE_LOG_FIELDS = "id,message,start,status,jobId"

function ConvertTo-XoRestoreLogObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo RestoreLog object

    .DESCRIPTION
    Convert an API response to an XO RestoreLog object.

    .PARAMETER InputObject
    RestoreLog input object from the API.

    .EXAMPLE
    ConvertTo-XoRestoreLogObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.RestoreLog")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            RestoreLogId = $InputObject.id
        }
        Set-XoObject $InputObject -TypeName XoPowershell.RestoreLog -Properties $props
    }
}

# SPDX-License-Identifier: Apache-2.0

$script:XO_BACKUP_LOG_FIELDS = "id,jobId,jobName,message,scheduleId,start,status"

function ConvertTo-XoBackupLogObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo BackupLog object

    .DESCRIPTION
    Convert an API response to an XO BackupLog object.

    .PARAMETER InputObject
    BackupLog input object from the API.

    .EXAMPLE
    ConvertTo-XoBackupLogObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.BackupLog")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            BackupLogId = $InputObject.id
        }
        Set-XoObject $InputObject -TypeName XoPowershell.BackupLog -Properties $props
    }
}

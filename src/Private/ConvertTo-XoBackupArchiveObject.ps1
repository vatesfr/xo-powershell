# SPDX-License-Identifier: Apache-2.0

$script:XO_BACKUP_ARCHIVE_FIELDS = "id,backupRepository,disks,type"

function ConvertTo-XoBackupArchiveObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo BackupArchive object

    .DESCRIPTION
    Convert an API response to an XO BackupArchive object.

    .PARAMETER InputObject
    BackupArchive input object from the API.

    .EXAMPLE
    ConvertTo-XoBackupArchiveObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.BackupArchive")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            BackupArchiveId = $InputObject.id
        }
        Set-XoObject $InputObject -TypeName XoPowershell.BackupArchive -Properties $props
    }
}

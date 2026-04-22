# SPDX-License-Identifier: Apache-2.0

$script:XO_BACKUP_JOB_FIELDS = "id,name,mode,type"

function ConvertTo-XoBackupJobObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo BackupJob object

    .DESCRIPTION
    Convert an API response to an XO backup job object.

    .PARAMETER InputObject
    Backup job input object from the API.

    .EXAMPLE
    ConvertTo-XoBackupJobObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.BackupJob")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            BackupJobId = $InputObject.id
        }
        Set-XoObject $InputObject -TypeName XoPowershell.BackupJob -Properties $props
    }
}

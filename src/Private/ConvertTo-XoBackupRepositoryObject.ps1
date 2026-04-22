# SPDX-License-Identifier: Apache-2.0

$script:XO_BACKUP_REPOSITORY_FIELDS = "id,name,enabled,url"

function ConvertTo-XoBackupRepositoryObject
{
    <#
    .SYNOPSIS
    Convert api object to powershell xo BackupRepository object

    .DESCRIPTION
    Convert an API response to an XO BackupRepository object.

    .PARAMETER InputObject
    BackupRepository input object from the API.

    .EXAMPLE
    ConvertTo-XoBackupRepositoryObject -InputObject $object
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.BackupRepository")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject
    )

    process
    {
        $props = @{
            BackupRepositoryId = $InputObject.id
            Name = $InputObject.name
        }
        Set-XoObject $InputObject -TypeName XoPowershell.BackupRepository -Properties $props
    }
}

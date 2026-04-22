# SPDX-License-Identifier: Apache-2.0

function Get-XoBackupArchive
{
    <#
    .SYNOPSIS
        List or query Xen Orchestra backup archives.
    .DESCRIPTION
        Retrieves Xen Orchestra backup archives - restorable snapshots stored in a backup repository. When called without parameters the cmdlet returns up to the session-wide limit (see Set-XoSession); supply -BackupArchiveId to fetch specific entries or -Filter / -Limit to scope a list query.
    .PARAMETER BackupArchiveId
        One or more IDs of the backup archives to retrieve. When omitted, the cmdlet enumerates backup archives using Filter and Limit.
    .PARAMETER Filter
        XO filter expression applied server-side (same syntax as the REST `filter` query parameter, e.g. `status:success`).
    .PARAMETER Limit
        Maximum number of backup archives to return when listing. Defaults to the session limit set by Connect-XoSession or Set-XoSession.
    .EXAMPLE
        Get-XoBackupArchive -Filter 'type:xo-vm-backup'
    .EXAMPLE
        Get-XoBackupArchive -BackupArchiveId "<id>"
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    [OutputType("XoPowershell.BackupArchive")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "BackupArchiveId")]
        [string[]]$BackupArchiveId,

        [Parameter(ParameterSetName = "Filter")]
        [string]$Filter,

        [Parameter(ParameterSetName = "Filter")]
        [int]$Limit = $script:XoSessionLimit
    )

    begin
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }

        $params = @{}
        $params["fields"] = $script:XO_BACKUP_ARCHIVE_FIELDS
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "BackupArchiveId")
        {
            foreach ($id in $BackupArchiveId)
            {
                $uri = "$script:XoHost/rest/v0/backup-archives/$id"
                ConvertTo-XoBackupArchiveObject (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params)
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            if ($Filter) { $params["filter"] = $Filter }
            if ($Limit)  { $params["limit"] = $Limit }

            $uri = "$script:XoHost/rest/v0/backup-archives"
            # the parentheses forces the resulting array to unpack, don't remove them!
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoBackupArchiveObject
        }
    }
}


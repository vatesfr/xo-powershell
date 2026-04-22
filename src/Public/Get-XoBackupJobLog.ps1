# SPDX-License-Identifier: Apache-2.0

function Get-XoBackupJobLog
{
    <#
    .SYNOPSIS
        List or query Xen Orchestra backup job logs.
    .DESCRIPTION
        Retrieves run logs for Xen Orchestra backup jobs via the /backup/logs endpoint (alias of Get-XoBackupLog using the alternative path). When called without parameters the cmdlet returns up to the session-wide limit (see Set-XoSession); supply -BackupLogId to fetch specific entries or -Filter / -Limit to scope a list query.
    .PARAMETER BackupLogId
        One or more IDs of the backup job logs to retrieve. When omitted, the cmdlet enumerates backup job logs using Filter and Limit.
    .PARAMETER Filter
        XO filter expression applied server-side (same syntax as the REST `filter` query parameter, e.g. `status:success`).
    .PARAMETER Limit
        Maximum number of backup job logs to return when listing. Defaults to the session limit set by Connect-XoSession or Set-XoSession.
    .EXAMPLE
        Get-XoBackupJobLog -Limit 50
    .EXAMPLE
        Get-XoBackupJobLog -BackupLogId "<id>"
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    [OutputType("XoPowershell.BackupLog")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "BackupLogId")]
        [string[]]$BackupLogId,

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
        $params["fields"] = $script:XO_BACKUP_LOG_FIELDS
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "BackupLogId")
        {
            foreach ($id in $BackupLogId)
            {
                $uri = "$script:XoHost/rest/v0/backup/logs/$id"
                ConvertTo-XoBackupLogObject (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params)
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            if ($Filter) { $params["filter"] = $Filter }
            if ($Limit)  { $params["limit"] = $Limit }

            $uri = "$script:XoHost/rest/v0/backup/logs"
            # the parentheses forces the resulting array to unpack, don't remove them!
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoBackupLogObject
        }
    }
}


# SPDX-License-Identifier: Apache-2.0

function Get-XoBackupRepository
{
    <#
    .SYNOPSIS
        List or query Xen Orchestra backup repositories.
    .DESCRIPTION
        Retrieves backup repositories (remotes) configured in Xen Orchestra - the destinations where backup archives are stored. When called without parameters the cmdlet returns up to the session-wide limit (see Set-XoSession); supply -BackupRepositoryId to fetch specific entries or -Filter / -Limit to scope a list query.
    .PARAMETER BackupRepositoryId
        One or more IDs of the backup repositories to retrieve. When omitted, the cmdlet enumerates backup repositories using Filter and Limit.
    .PARAMETER Filter
        XO filter expression applied server-side (same syntax as the REST `filter` query parameter, e.g. `status:success`).
    .PARAMETER Limit
        Maximum number of backup repositories to return when listing. Defaults to the session limit set by Connect-XoSession or Set-XoSession.
    .EXAMPLE
        Get-XoBackupRepository | Where-Object enabled
    .EXAMPLE
        Get-XoBackupRepository -BackupRepositoryId "<id>"
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    [OutputType("XoPowershell.BackupRepository")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "BackupRepositoryId")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$BackupRepositoryId,

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
        $params["fields"] = $script:XO_BACKUP_REPOSITORY_FIELDS
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "BackupRepositoryId")
        {
            foreach ($id in $BackupRepositoryId)
            {
                $uri = "$script:XoHost/rest/v0/backup-repositories/$id"
                ConvertTo-XoBackupRepositoryObject (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params)
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            if ($Filter) { $params["filter"] = $Filter }
            if ($Limit)  { $params["limit"] = $Limit }

            $uri = "$script:XoHost/rest/v0/backup-repositories"
            # the parentheses forces the resulting array to unpack, don't remove them!
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoBackupRepositoryObject
        }
    }
}


# SPDX-License-Identifier: Apache-2.0

function Get-XoBackupJob
{
    <#
    .SYNOPSIS
        List or query backup jobs.
    .DESCRIPTION
        Get Xen Orchestra backup jobs by ID or list all existing backup jobs.
    .PARAMETER BackupJobId
        The ID(s) of the backup job(s) to retrieve.
    .PARAMETER Filter
        Custom filter expression for the backup job query.
    .PARAMETER Limit
        Maximum number of backup jobs to return.
    .EXAMPLE
        Get-XoBackupJob -BackupJobId "d33f3dc1-92b4-469c-ad58-4c2a106a4721"
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    [OutputType("XoPowershell.BackupJob")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "BackupJobId")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$BackupJobId,

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

        $params = @{
            fields = $script:XO_BACKUP_JOB_FIELDS
        }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "BackupJobId")
        {
            foreach ($id in $BackupJobId)
            {
                $uri = "$script:XoHost/rest/v0/backup-jobs/$id"
                ConvertTo-XoBackupJobObject (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params)
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            if ($Filter)
            {
                $params["filter"] = $Filter
            }

            if ($Limit)
            {
                $params["limit"] = $Limit
            }

            $uri = "$script:XoHost/rest/v0/backup-jobs"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoBackupJobObject
        }
    }
}

# SPDX-License-Identifier: Apache-2.0

function Get-XoBackupJobVm
{
    <#
    .SYNOPSIS
        List or query Xen Orchestra VM backup jobs.
    .DESCRIPTION
        Retrieves VM backup jobs - the jobs that snapshot and archive VMs to a backup repository. When called without parameters the cmdlet returns up to the session-wide limit (see Set-XoSession); supply -BackupJobId to fetch specific entries or -Filter / -Limit to scope a list query.
    .PARAMETER BackupJobId
        One or more IDs of the VM backup jobs to retrieve. When omitted, the cmdlet enumerates VM backup jobs using Filter and Limit.
    .PARAMETER Filter
        XO filter expression applied server-side (same syntax as the REST `filter` query parameter, e.g. `status:success`).
    .PARAMETER Limit
        Maximum number of VM backup jobs to return when listing. Defaults to the session limit set by Connect-XoSession or Set-XoSession.
    .EXAMPLE
        Get-XoBackupJobVm
    .EXAMPLE
        Get-XoBackupJobVm -BackupJobId "<id>"
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

        $params = @{}
        $params["fields"] = $script:XO_BACKUP_JOB_FIELDS
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "BackupJobId")
        {
            foreach ($id in $BackupJobId)
            {
                $uri = "$script:XoHost/rest/v0/backup/jobs/vm/$id"
                ConvertTo-XoBackupJobObject (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params)
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            if ($Filter) { $params["filter"] = $Filter }
            if ($Limit)  { $params["limit"] = $Limit }

            $uri = "$script:XoHost/rest/v0/backup/jobs/vm"
            # the parentheses forces the resulting array to unpack, don't remove them!
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoBackupJobObject
        }
    }
}


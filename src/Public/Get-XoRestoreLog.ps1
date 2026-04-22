# SPDX-License-Identifier: Apache-2.0

function Get-XoRestoreLog
{
    <#
    .SYNOPSIS
        List or query Xen Orchestra restore logs.
    .DESCRIPTION
        Retrieves restore logs - the per-run records produced when a backup archive is restored to a VM or SR. When called without parameters the cmdlet returns up to the session-wide limit (see Set-XoSession); supply -RestoreLogId to fetch specific entries or -Filter / -Limit to scope a list query.
    .PARAMETER RestoreLogId
        One or more IDs of the restore logs to retrieve. When omitted, the cmdlet enumerates restore logs using Filter and Limit.
    .PARAMETER Filter
        XO filter expression applied server-side (same syntax as the REST `filter` query parameter, e.g. `status:success`).
    .PARAMETER Limit
        Maximum number of restore logs to return when listing. Defaults to the session limit set by Connect-XoSession or Set-XoSession.
    .EXAMPLE
        Get-XoRestoreLog -Filter 'status:failure'
    .EXAMPLE
        Get-XoRestoreLog -RestoreLogId "<id>"
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    [OutputType("XoPowershell.RestoreLog")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "RestoreLogId")]
        [string[]]$RestoreLogId,

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
        $params["fields"] = $script:XO_RESTORE_LOG_FIELDS
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "RestoreLogId")
        {
            foreach ($id in $RestoreLogId)
            {
                $uri = "$script:XoHost/rest/v0/restore-logs/$id"
                ConvertTo-XoRestoreLogObject (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params)
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            if ($Filter) { $params["filter"] = $Filter }
            if ($Limit)  { $params["limit"] = $Limit }

            $uri = "$script:XoHost/rest/v0/restore-logs"
            # the parentheses forces the resulting array to unpack, don't remove them!
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoRestoreLogObject
        }
    }
}


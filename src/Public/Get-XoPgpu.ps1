# SPDX-License-Identifier: Apache-2.0

function Get-XoPgpu
{
    <#
    .SYNOPSIS
        List or query Xen Orchestra physical GPUs (PGPUs).
    .DESCRIPTION
        Retrieves physical GPUs attached to pool hosts, including their GPU group membership and dom0 access status. When called without parameters the cmdlet returns up to the session-wide limit (see Set-XoSession); supply -PgpuUuid to fetch specific entries or -Filter / -Limit to scope a list query.
    .PARAMETER PgpuUuid
        One or more IDs of the physical GPUs (PGPUs) to retrieve. When omitted, the cmdlet enumerates physical GPUs (PGPUs) using Filter and Limit.
    .PARAMETER Filter
        XO filter expression applied server-side (same syntax as the REST `filter` query parameter, e.g. `status:success`).
    .PARAMETER Limit
        Maximum number of physical GPUs (PGPUs) to return when listing. Defaults to the session limit set by Connect-XoSession or Set-XoSession.
    .EXAMPLE
        Get-XoPgpu
    .EXAMPLE
        Get-XoPgpu -PgpuUuid "<id>"
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    [OutputType("XoPowershell.Pgpu")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "PgpuUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$PgpuUuid,

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
        $params["fields"] = $script:XO_PGPU_FIELDS
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "PgpuUuid")
        {
            foreach ($id in $PgpuUuid)
            {
                $uri = "$script:XoHost/rest/v0/pgpus/$id"
                ConvertTo-XoPgpuObject (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params)
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            if ($Filter) { $params["filter"] = $Filter }
            if ($Limit)  { $params["limit"] = $Limit }

            $uri = "$script:XoHost/rest/v0/pgpus"
            # the parentheses forces the resulting array to unpack, don't remove them!
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoPgpuObject
        }
    }
}


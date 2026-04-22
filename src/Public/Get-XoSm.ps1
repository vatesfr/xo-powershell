# SPDX-License-Identifier: Apache-2.0

function Get-XoSm
{
    <#
    .SYNOPSIS
        List or query Xen Orchestra storage managers (SMs).
    .DESCRIPTION
        Retrieves XAPI storage manager plugins installed on pool hosts. Each SM corresponds to a supported SR type (ext, lvm, nfs, ...). When called without parameters the cmdlet returns up to the session-wide limit (see Set-XoSession); supply -SmUuid to fetch specific entries or -Filter / -Limit to scope a list query.
    .PARAMETER SmUuid
        One or more IDs of the storage managers (SMs) to retrieve. When omitted, the cmdlet enumerates storage managers (SMs) using Filter and Limit.
    .PARAMETER Filter
        XO filter expression applied server-side (same syntax as the REST `filter` query parameter, e.g. `status:success`).
    .PARAMETER Limit
        Maximum number of storage managers (SMs) to return when listing. Defaults to the session limit set by Connect-XoSession or Set-XoSession.
    .EXAMPLE
        Get-XoSm | Sort-Object -Property SM_type
    .EXAMPLE
        Get-XoSm -SmUuid "<id>"
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    [OutputType("XoPowershell.Sm")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "SmUuid")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$SmUuid,

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
        $params["fields"] = $script:XO_SM_FIELDS
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "SmUuid")
        {
            foreach ($id in $SmUuid)
            {
                $uri = "$script:XoHost/rest/v0/sms/$id"
                ConvertTo-XoSmObject (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params)
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

            $uri = "$script:XoHost/rest/v0/sms"
            # the parentheses forces the resulting array to unpack, don't remove them!
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoSmObject
        }
    }
}


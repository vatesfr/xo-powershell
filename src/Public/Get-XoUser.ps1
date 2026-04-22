# SPDX-License-Identifier: Apache-2.0

function Get-XoUser
{
    <#
    .SYNOPSIS
        List or query Xen Orchestra users.
    .DESCRIPTION
        Retrieves Xen Orchestra users, including their permission level, email and group membership. When called without parameters the cmdlet returns up to the session-wide limit (see Set-XoSession); supply -UserId to fetch specific entries or -Filter / -Limit to scope a list query.
    .PARAMETER UserId
        One or more IDs of the users to retrieve. When omitted, the cmdlet enumerates users using Filter and Limit.
    .PARAMETER Filter
        XO filter expression applied server-side (same syntax as the REST `filter` query parameter, e.g. `status:success`).
    .PARAMETER Limit
        Maximum number of users to return when listing. Defaults to the session limit set by Connect-XoSession or Set-XoSession.
    .EXAMPLE
        Get-XoUser | Where-Object permission -eq 'admin'
    .EXAMPLE
        Get-XoUser -UserId "<id>"
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    [OutputType("XoPowershell.User")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "UserId")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$UserId,

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
        $params["fields"] = $script:XO_USER_FIELDS
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "UserId")
        {
            foreach ($id in $UserId)
            {
                $uri = "$script:XoHost/rest/v0/users/$id"
                ConvertTo-XoUserObject (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params)
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            if ($Filter) { $params["filter"] = $Filter }
            if ($Limit)  { $params["limit"] = $Limit }

            $uri = "$script:XoHost/rest/v0/users"
            # the parentheses forces the resulting array to unpack, don't remove them!
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoUserObject
        }
    }
}


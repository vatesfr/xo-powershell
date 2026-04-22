# SPDX-License-Identifier: Apache-2.0

function Get-XoGroup
{
    <#
    .SYNOPSIS
        List or query Xen Orchestra groups.
    .DESCRIPTION
        Retrieves user groups configured in Xen Orchestra. Groups are used to grant permissions to collections of users. When called without parameters the cmdlet returns up to the session-wide limit (see Set-XoSession); supply -GroupId to fetch specific entries or -Filter / -Limit to scope a list query.
    .PARAMETER GroupId
        One or more IDs of the groups to retrieve. When omitted, the cmdlet enumerates groups using Filter and Limit.
    .PARAMETER Filter
        XO filter expression applied server-side (same syntax as the REST `filter` query parameter, e.g. `status:success`).
    .PARAMETER Limit
        Maximum number of groups to return when listing. Defaults to the session limit set by Connect-XoSession or Set-XoSession.
    .EXAMPLE
        Get-XoGroup
    .EXAMPLE
        Get-XoGroup -GroupId "<id>"
    #>
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    [OutputType("XoPowershell.Group")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = "GroupId")]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$GroupId,

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
        $params["fields"] = $script:XO_GROUP_FIELDS
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "GroupId")
        {
            foreach ($id in $GroupId)
            {
                $uri = "$script:XoHost/rest/v0/groups/$id"
                ConvertTo-XoGroupObject (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params)
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "Filter")
        {
            if ($Filter) { $params["filter"] = $Filter }
            if ($Limit)  { $params["limit"] = $Limit }

            $uri = "$script:XoHost/rest/v0/groups"
            # the parentheses forces the resulting array to unpack, don't remove them!
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoGroupObject
        }
    }
}


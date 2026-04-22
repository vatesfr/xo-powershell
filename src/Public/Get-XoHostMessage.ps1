# SPDX-License-Identifier: Apache-2.0

function Get-XoHostMessage
{
    <#
    .SYNOPSIS
        Get messages scoped to a specific host.
    .DESCRIPTION
        Retrieves messages attached to the specified Xen Orchestra host. Accepts one or more host UUIDs; each is queried independently and the combined results are returned.
    .PARAMETER HostUuid
        The UUID(s) of the host whose messages should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoHostMessage -HostUuid "812b59e1-2682-43ef-acd4-808d3551b907"
    .EXAMPLE
        Get-XoHost | Get-XoHostMessage
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Message")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$HostUuid
    )

    begin
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }

        $params = @{}
        $params["fields"] = $script:XO_MESSAGE_FIELDS
    }

    process
    {
        foreach ($id in $HostUuid)
        {
            $uri = "$script:XoHost/rest/v0/hosts/$id/messages"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoMessageObject
        }
    }
}


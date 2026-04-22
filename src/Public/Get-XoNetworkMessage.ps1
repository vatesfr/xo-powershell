# SPDX-License-Identifier: Apache-2.0

function Get-XoNetworkMessage
{
    <#
    .SYNOPSIS
        Get messages scoped to a specific network.
    .DESCRIPTION
        Retrieves messages attached to the specified Xen Orchestra network. Accepts one or more network UUIDs; each is queried independently and the combined results are returned.
    .PARAMETER NetworkUuid
        The UUID(s) of the network whose messages should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoNetworkMessage -NetworkUuid "00000000-0000-0000-0000-000000000000"
    .EXAMPLE
        Get-XoNetwork | Get-XoNetworkMessage
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Message")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$NetworkUuid
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
        foreach ($id in $NetworkUuid)
        {
            $uri = "$script:XoHost/rest/v0/networks/$id/messages"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoMessageObject
        }
    }
}


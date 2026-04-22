# SPDX-License-Identifier: Apache-2.0

function Get-XoVdiMessage
{
    <#
    .SYNOPSIS
        Get messages scoped to a specific VDI.
    .DESCRIPTION
        Retrieves messages attached to the specified Xen Orchestra VDI. Accepts one or more VDI UUIDs; each is queried independently and the combined results are returned.
    .PARAMETER VdiUuid
        The UUID(s) of the VDI whose messages should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoVdiMessage -VdiUuid "00000000-0000-0000-0000-000000000000"
    .EXAMPLE
        Get-XoVdi | Get-XoVdiMessage
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Message")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$VdiUuid
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
        foreach ($id in $VdiUuid)
        {
            $uri = "$script:XoHost/rest/v0/vdis/$id/messages"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoMessageObject
        }
    }
}


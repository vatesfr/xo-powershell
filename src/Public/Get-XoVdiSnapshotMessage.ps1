# SPDX-License-Identifier: Apache-2.0

function Get-XoVdiSnapshotMessage
{
    <#
    .SYNOPSIS
        Get messages scoped to a specific VDI snapshot.
    .DESCRIPTION
        Retrieves messages attached to the specified Xen Orchestra VDI snapshot. Accepts one or more VDI snapshot UUIDs; each is queried independently and the combined results are returned.
    .PARAMETER VdiSnapshotUuid
        The UUID(s) of the VDI snapshot whose messages should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoVdiSnapshotMessage -VdiSnapshotUuid "00000000-0000-0000-0000-000000000000"
    .EXAMPLE
        Get-XoVdiSnapshot | Get-XoVdiSnapshotMessage
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Message")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$VdiSnapshotUuid
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
        foreach ($id in $VdiSnapshotUuid)
        {
            $uri = "$script:XoHost/rest/v0/vdi-snapshots/$id/messages"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoMessageObject
        }
    }
}


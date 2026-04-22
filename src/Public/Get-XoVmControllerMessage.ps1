# SPDX-License-Identifier: Apache-2.0

function Get-XoVmControllerMessage
{
    <#
    .SYNOPSIS
        Get messages scoped to a specific VM controller.
    .DESCRIPTION
        Retrieves messages attached to the specified Xen Orchestra VM controller. Accepts one or more VM controller UUIDs; each is queried independently and the combined results are returned.
    .PARAMETER VmControllerUuid
        The UUID(s) of the VM controller whose messages should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoVmControllerMessage -VmControllerUuid "00000000-0000-0000-0000-000000000000"
    .EXAMPLE
        Get-XoVmController | Get-XoVmControllerMessage
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.Message")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string[]]$VmControllerUuid
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
        foreach ($id in $VmControllerUuid)
        {
            $uri = "$script:XoHost/rest/v0/vm-controllers/$id/messages"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoMessageObject
        }
    }
}


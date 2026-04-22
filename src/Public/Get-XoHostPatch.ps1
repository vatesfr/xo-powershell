# SPDX-License-Identifier: Apache-2.0

function Get-XoHostPatch
{
    <#
    .SYNOPSIS
        Get missing patches scoped to a specific host.
    .DESCRIPTION
        Retrieves missing patches attached to the specified Xen Orchestra host. Accepts one or more host UUIDs; each is queried independently and the combined results are returned.
    .PARAMETER HostUuid
        The UUID(s) of the host whose missing patches should be returned. Accepts pipeline input by property name.
    .EXAMPLE
        Get-XoHostPatch -HostUuid "812b59e1-2682-43ef-acd4-808d3551b907"
    .EXAMPLE
        Get-XoHost | Get-XoHostPatch
    #>
    [CmdletBinding()]
    [OutputType("XoPowershell.PoolPatch")]
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

    }

    process
    {
        foreach ($id in $HostUuid)
        {
            $uri = "$script:XoHost/rest/v0/hosts/$id/missing_patches"
            (Invoke-RestMethod -Uri $uri @script:XoRestParameters -Body $params) | ConvertTo-XoPoolPatchObject
        }
    }
}


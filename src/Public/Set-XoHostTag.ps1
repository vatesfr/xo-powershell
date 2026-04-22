# SPDX-License-Identifier: Apache-2.0

function Set-XoHostTag
{
    <#
    .SYNOPSIS
        Attach or detach a single tag on a Xen Orchestra host.
    .DESCRIPTION
        Manages individual tags on the specified host using the /tags/{tag} endpoint. By default the tag is added (HTTP PUT); pass -Remove to detach it (HTTP DELETE). Unlike Set-Xo* cmdlets, this does not replace the full tag list - only the single tag is modified.
    .PARAMETER HostUuid
        The UUID of the host to tag.
    .PARAMETER Tag
        The tag value to add or remove.
    .PARAMETER Remove
        Detach the tag instead of attaching it.
    .EXAMPLE
        Set-XoHostTag -HostUuid "<uuid>" -Tag "production"
    .EXAMPLE
        Set-XoHostTag -HostUuid "<uuid>" -Tag "production" -Remove
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [ValidateNotNullOrEmpty()]
        [string]$HostUuid,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Tag,

        [Parameter()]
        [switch]$Remove
    )

    process
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }

        $method = if ($Remove) { "Delete" } else { "Put" }
        $verb   = if ($Remove) { "remove tag '$Tag'" } else { "add tag '$Tag'" }

        if ($PSCmdlet.ShouldProcess($HostUuid, $verb))
        {
            $uri = "$script:XoHost/rest/v0/hosts/$HostUuid/tags/$Tag"
            Invoke-RestMethod -Uri $uri -Method $method @script:XoRestParameters
        }
    }
}


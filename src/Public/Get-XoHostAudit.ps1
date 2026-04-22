# SPDX-License-Identifier: Apache-2.0

function Get-XoHostAudit
{
    <#
    .SYNOPSIS
        Download the audit log for a Xen Orchestra host.
    .DESCRIPTION
        Downloads the plain-text XAPI audit log from /hosts/{id}/audit.txt. When -OutFile is supplied the file is written to disk; otherwise the content is returned as a string. Useful for compliance reporting and forensic investigation.
    .PARAMETER HostUuid
        The UUID of the host whose audit log to download.
    .PARAMETER OutFile
        Path to save the downloaded content to. If omitted, content is returned as a string.
    .EXAMPLE
        Get-XoHostAudit -HostUuid "812b59e1-2682-43ef-acd4-808d3551b907" -OutFile "./host-audit.txt"
    .EXAMPLE
        Get-XoHost | ForEach-Object { Get-XoHostAudit -HostUuid $_.HostUuid -OutFile "./audit-$($_.Name).txt" }
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidatePattern("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")]
        [string]$HostUuid,

        [Parameter()]
        [string]$OutFile
    )

    process
    {
        if (-not $script:XoHost -or -not $script:XoRestParameters)
        {
            throw "Not connected to Xen Orchestra. Call Connect-XoSession first."
        }

        $uri = "$script:XoHost/rest/v0/hosts/$HostUuid/audit.txt"
        if ($OutFile)
        {
            Invoke-RestMethod -Uri $uri @script:XoRestParameters -OutFile $OutFile
            Get-Item $OutFile
        }
        else
        {
            Invoke-RestMethod -Uri $uri @script:XoRestParameters
        }
    }
}


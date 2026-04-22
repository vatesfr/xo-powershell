# SPDX-License-Identifier: Apache-2.0

function Get-XoHostLogBundle
{
    <#
    .SYNOPSIS
        Download the diagnostic log bundle for a Xen Orchestra host.
    .DESCRIPTION
        Downloads the compressed .tgz log bundle from /hosts/{id}/logs.tgz. The bundle contains xensource.log, messages, xapi database dumps and other data that support engineers typically ask for. When -OutFile is supplied the file is written to disk.
    .PARAMETER HostUuid
        The UUID of the host whose log bundle to download.
    .PARAMETER OutFile
        Path to save the downloaded .tgz to. If omitted, content is streamed back as bytes.
    .EXAMPLE
        Get-XoHostLogBundle -HostUuid "812b59e1-2682-43ef-acd4-808d3551b907" -OutFile "./host-logs.tgz"
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

        $uri = "$script:XoHost/rest/v0/hosts/$HostUuid/logs.tgz"
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


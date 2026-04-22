# SPDX-License-Identifier: Apache-2.0

function Invoke-XoRestMethod
{
    <#
    .SYNOPSIS
        Helper for when Invoke-RestMethod returns unparseable JSON.
    .DESCRIPTION
        Helper for when Invoke-RestMethod returns unparseable JSON (e.g. due to duplicate keys). $script:XoRestParameters is already included.

    .PARAMETER Uri
    Target Xen Orchestra REST URL.

    .PARAMETER Body
    Body content for the REST request.

    .EXAMPLE
    Invoke-XoRestMethod -Uri $Url -Body $body
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Uri,

        [Parameter()]
        [object]$Body
    )

    $result = Invoke-RestMethod @script:XoRestParameters -Uri $uri -Body $body
    if ($result -is [string])
    {
        Write-Verbose "server returned unparseable JSON, retrying with -AsHashtable"
        $json = $result | ConvertFrom-Json -AsHashtable
        return [pscustomobject]$json
    }
    else
    {
        return $result
    }
}

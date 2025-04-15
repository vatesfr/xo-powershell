# SPDX-License-Identifier: Apache-2.0

function Remove-XoEmptyValues {
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][ValidateNotNull()][System.Collections.IDictionary]$InputObject
    )
    $ret = @{}
    foreach ($kv in $InputObject.GetEnumerator()) {
        if ($null -ne $kv.Value -and ![string]::IsNullOrEmpty($kv.Value -as [string])) {
            $ret.Add($kv.Key, $kv.Value)
        }
    }
    return $ret
}

function Set-XoObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]$InputObject,
        [Parameter()][string]$TypeName,
        [Parameter()][hashtable]$Properties
    )

    if ($TypeName) {
        $InputObject.PSObject.TypeNames.Insert(0, $TypeName) > $null
    }
    if ($Properties) {
        foreach ($key in $Properties.Keys) {
            $InputObject.PSObject.Properties.Add([psnoteproperty]::new($key, $Properties[$key])) > $null
        }
    }
    [PSCustomObject]$InputObject
}

function ConvertFrom-XoSecureString {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)][securestring]$SecureString
    )

    process {
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
        try {
            return [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
        }
        finally {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }
}

function Format-XoSize {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][long]$Value
    )

    # based off of https://stackoverflow.com/a/40887001/8642889

    $suffix = " B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"
    $index = 0
    while ($Value -gt 1kb -and $index -lt $suffix.Length) {
        $Value = $Value / 1kb
        $index++
    }

    "{0:N1} {1}" -f $Value, $suffix[$index]
}

function ConvertFrom-XoUuidHref {
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][string]$Uri
    )

    process {
        if ($Uri -notmatch "\/rest\/v0\/[0-9a-z-_]+\/[0-9a-z-]+") {
            throw "Bad href format"
        }
        [uri]::new([uri]$script:XoHost, $Uri).Segments[-1]
    }
}

function Invoke-XoRestMethod {
    <#
    .SYNOPSIS
        Helper for when Invoke-RestMethod returns unparseable JSON.
    .DESCRIPTION
        Helper for when Invoke-RestMethod returns unparseable JSON (e.g. due to duplicate keys). $script:XoRestParameters is already included.
    #>
    param(
        [Parameter(Mandatory)][string]$Uri,
        [Parameter()][object]$Body
    )

    $result = Invoke-RestMethod @script:XoRestParameters -Uri $uri -Body $body
    if ($result -is [string]) {
        Write-Verbose "server returned unparseable JSON, retrying with -AsHashtable"
        return [pscustomobject](ConvertFrom-Json -AsHashtable $result)
    } else {
        return $result
    }
}

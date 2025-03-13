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
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][System.Object[]]$InputObject,
        [Parameter()][string]$TypeName,
        [Parameter()][hashtable]$Properties,
        [Parameter()][switch]$Foo
    )

    process {
        foreach ($obj in $InputObject) {
            if ($TypeName) {
                $obj.PSObject.TypeNames.Insert(0, $TypeName) > $null
            }
            if ($Properties) {
                foreach ($key in $Properties.Keys) {
                    $obj.PSObject.Properties.Add([psnoteproperty]::new($key, $Properties[$key])) > $null
                }
            }
            [PSCustomObject]$obj
        }
    }
}

function Format-XoSize {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][long]$Value
    )

    # based off of https://stackoverflow.com/a/40887001/8642889

    $suffix = "B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"
    $index = 0
    while ($Value -gt 1kb -and $index -lt $suffix.Length) {
        $Value = $Value / 1kb
        $index++
    }

    "{0:N1} {1}" -f $Value, $suffix[$index]
}

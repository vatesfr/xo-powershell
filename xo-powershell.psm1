# SPDX-License-Identifier: Apache-2.0

$ErrorActionPreference = "Stop"

# Module-level variables
$script:XoHost = $null
$script:XoRestParameters = $null
$script:XO_DEFAULT_LIMIT = 25

foreach ($import in (Get-ChildItem $PSScriptRoot/src/*.ps1)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error -Message "Cannot import $($import.FullName): $_"
        throw
    }
}

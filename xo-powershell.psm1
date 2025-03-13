$ErrorActionPreference = "Stop"

# Module-level variables
$script:XoHost = $null
$script:XoRestParameters = $null

foreach ($import in (Get-ChildItem $PSScriptRoot/src/*.ps1)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error -Message "Cannot import $($import.FullName): $_"
        throw
    }
}

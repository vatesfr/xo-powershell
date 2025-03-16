1. Cmdlets should follow the [approved verbs list](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands) to maintain consistency (e.g. `Get-XoTask`, `Get-XoVM`, `New-XoVMSnapshot` etc.)
2. `SkipCertificateCheck` should be explicitly specified per session or per user.
3. Session connection should be explicitly made with cmdlets like `Connect-XenOrchestra` and `Disconnect-XenOrchestra` for automation.
4. Module-level variables should not be globals (e.g. by using `$Script:VariableName`).
5. All cmdlets should have "native PowerShell" documentation, accessible via Get-Help (with `.SYNOPSIS`, `.DESCRIPTION`, comments/parameter constraints, `Validate` and `ArgumentCompletions` etc.).
6. Cmdlet output should be pipelineable (e.g. `Get-XoVM | Get-XoVMSnapshot`), and work with multiple inputs (e.g. `Get-XoVM | Where-Object ... | Stop-XoVM`).
7. Cmdlet output should be formatted by default (as seen when you type `dir`) without affecting pipelines. You can do this using .ps1xml files, `ViewDefinitions` and `PSObject.TypeNames`.
8. Destructive cmdlets must support `-Confirm` (by default, with `ConfirmImpact`) and `-WhatIf`.

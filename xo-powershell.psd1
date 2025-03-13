@{
    RootModule        = 'xo-powershell.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'adaf591c-6abd-4084-89f9-d75a9096743d'
    Author            = 'Your Name'
    CompanyName       = 'Vates'
    Copyright         = 'Copyright (c) Vates. All rights reserved - TBD'
    Description       = 'Xen Orchestra PowerShell module'
    PowerShellVersion = '7.0'
    FunctionsToExport = @(
        # session.ps1
        "Test-XoSession"
        "Connect-XoSession"
        "Disconnect-XoSession"
        # vm.ps1
        "Get-XoVm"
        "Get-XoVmVdi"
        "Stop-XoVm"
    )
    AliasesToExport   = @(
        "Connect-XenOrchestra"
        "Disconnect-XenOrchestra"
    )
    FormatsToProcess  = @(
        "formats/vm.ps1xml"
        "formats/vdi.ps1xml"
    )
}

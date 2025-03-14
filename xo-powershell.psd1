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
        # session
        "Test-XoSession"
        "Connect-XoSession"
        "Disconnect-XoSession"
        # task
        "Get-XoTask"
        "Wait-XoTask"
        # vm
        "Get-XoVm"
        "Get-XoVmVdi"
        "Start-XoVm"
        "Stop-XoVm"
        "Restart-XoVm"
        "New-XoVmSnapshot"
    )
    AliasesToExport   = @(
        "Connect-XenOrchestra"
        "Disconnect-XenOrchestra"
        # task
        "Get-XoTaskDetails"
    )
    FormatsToProcess  = @(
        "formats/task.ps1xml"
        "formats/vdi.ps1xml"
        "formats/vm.ps1xml"
    )
}

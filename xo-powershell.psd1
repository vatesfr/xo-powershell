@{
    RootModule        = 'xo-powershell.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'adaf591c-6abd-4084-89f9-d75a9096743d'
    Author            = 'Vates'
    CompanyName       = 'Vates'
    Copyright         = 'Copyright (c) Vates.'
    Description       = 'Xen Orchestra PowerShell module'
    PowerShellVersion = '7.0'
    PrivateData       = @{
        PSData = @{
            LicenseUri = 'https://spdx.org/licenses/Apache-2.0.html'
            ProjectUri = 'https://github.com/vatesfr/xo-powershell'
            Prerelease = 'beta'
        }
    }
    FunctionsToExport = @(
        # session
        "Test-XoSession"
        "Connect-XoSession"
        "Disconnect-XoSession"
        "Get-XoSession"
        "Set-XoSession"

        # sr
        "Get-XoSr"
        "Set-XoSr"

        # task
        "Get-XoTask"
        "Wait-XoTask"

        # vdi
        "Get-XoVdi"
        "Set-XoVdi"
        "Export-XoVdi"

        # vdi-snapshot
        "Get-XoVdiSnapshot"
        "Export-XoVdiSnapshot"

        # vm
        "Get-XoVm"
        "Set-XoVm"
        "Get-XoVmVdi"
        "Start-XoVm"
        "Stop-XoVm"
        "Restart-XoVm"
        "Suspend-XoVm"

        # vm-snapshot
        "Get-XoVmSnapshot"
        "New-XoVmSnapshot"

        # server
        "Get-XoServer"

        # host
        "Get-XoHost"
        "Set-XoHost"

        # pool
        "Get-XoPool"
        "Set-XoPool"
        "Get-XoPoolMessage"
        "Restart-XoPool"
        "Stop-XoPool"
        "Update-XoPool"

        # pool-patch
        "Get-XoPoolPatch"

        # message
        "Get-XoMessage"

        # network
        "Get-XoNetwork"
        "Set-XoNetwork"

        # pif
        "Get-XoPif"
        "Set-XoPif"

        # vif
        "Get-XoVif"
        "Set-XoVif"

        # vbd
        "Get-XoVbd"
    )
    AliasesToExport   = @(
        "Connect-XenOrchestra"
        "Disconnect-XenOrchestra"
        # task
        "Get-XoTaskDetails"
    )
    FormatsToProcess  = @(
        "formats/sr.ps1xml"
        "formats/task.ps1xml"
        "formats/vdi.ps1xml"
        "formats/vm.ps1xml"
        "formats/vdi-snapshot.ps1xml"
        "formats/vm-snapshot.ps1xml"
        "formats/server.ps1xml"
        "formats/host.ps1xml"
        "formats/pool.ps1xml"
        "formats/pool-patch.ps1xml"
        "formats/message.ps1xml"
        "formats/network.ps1xml"
        "formats/pif.ps1xml"
        "formats/vif.ps1xml"
        "formats/vbd.ps1xml"
    )
}

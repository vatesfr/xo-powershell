@{
    RootModule = 'xo-cli.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'adaf591c-6abd-4084-89f9-d75a9096743d'
    Author = 'Your Name'
    Description = 'Xen Orchestra PowerShell CLI module'
    PowerShellVersion = '7.0'
    FunctionsToExport = @(
        'XoVms-List',
        'XoVms-Details',
        'XoVms-Action',
        'XoVms-Snapshot',
        'XoTasks-List',
        'XoTasks-Details'
    )
}

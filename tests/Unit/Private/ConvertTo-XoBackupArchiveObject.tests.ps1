BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoBackupArchiveObject {
    Context 'When called with a typical API object' {
        It 'Should produce a decorated XoPowershell.BackupArchive object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ id = '1af95910-01b4-4e87-9c2f-d895cafe0776'; backupRepository = 'repo-1'; disks = @(); type = 'xo-vm-backup' }

                $result = ConvertTo-XoBackupArchiveObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.BackupArchive'
                $result.BackupArchiveId | Should -Be '1af95910-01b4-4e87-9c2f-d895cafe0776'
                $result.backupRepository | Should -Be 'repo-1'
                $result.type | Should -Be 'xo-vm-backup'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ id = '1af95910-01b4-4e87-9c2f-d895cafe0776'; backupRepository = 'repo-1'; disks = @(); type = 'xo-vm-backup' }

                $result = $apiObject | ConvertTo-XoBackupArchiveObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.BackupArchive'
            }
        }
    }
}

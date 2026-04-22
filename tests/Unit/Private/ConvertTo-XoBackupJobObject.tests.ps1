BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoBackupJobObject {
    Context 'When called with a typical API object' {
        It 'Should produce a decorated XoPowershell.BackupJob object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ id = 'd33f3dc1-92b4-469c-ad58-4c2a106a4721'; name = 'nightly'; mode = 'full'; type = 'backup' }

                $result = ConvertTo-XoBackupJobObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.BackupJob'
                $result.BackupJobId | Should -Be 'd33f3dc1-92b4-469c-ad58-4c2a106a4721'
                $result.name | Should -Be 'nightly'
                $result.mode | Should -Be 'full'
                $result.type | Should -Be 'backup'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ id = 'd33f3dc1-92b4-469c-ad58-4c2a106a4721'; name = 'nightly'; mode = 'full'; type = 'backup' }

                $result = $apiObject | ConvertTo-XoBackupJobObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.BackupJob'
            }
        }
    }
}

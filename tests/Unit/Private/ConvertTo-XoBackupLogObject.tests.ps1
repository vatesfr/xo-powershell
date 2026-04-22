BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoBackupLogObject {
    Context 'When called with a typical API object' {
        It 'Should produce a decorated XoPowershell.BackupLog object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ id = '1753776067468'; jobId = '59af07fc-e82c-43b5-8137-026832f30166'; jobName = 'test-modal'; status = 'success'; message = 'backup'; start = 1753776067468 }

                $result = ConvertTo-XoBackupLogObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.BackupLog'
                $result.BackupLogId | Should -Be '1753776067468'
                $result.jobName | Should -Be 'test-modal'
                $result.status | Should -Be 'success'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ id = '1753776067468'; jobId = '59af07fc-e82c-43b5-8137-026832f30166'; jobName = 'test-modal'; status = 'success'; message = 'backup'; start = 1753776067468 }

                $result = $apiObject | ConvertTo-XoBackupLogObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.BackupLog'
            }
        }
    }
}

BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoBackupRepositoryObject {
    Context 'When called with a typical API object' {
        It 'Should produce a decorated XoPowershell.BackupRepository object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ id = '677e50c5-8d8a-4c89-b1ac-e2f4593d0ebb'; name = 'S3_Remote'; enabled = $true; url = 's3://example' }

                $result = ConvertTo-XoBackupRepositoryObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.BackupRepository'
                $result.BackupRepositoryId | Should -Be '677e50c5-8d8a-4c89-b1ac-e2f4593d0ebb'
                $result.Name | Should -Be 'S3_Remote'
                $result.enabled | Should -BeTrue
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ id = '677e50c5-8d8a-4c89-b1ac-e2f4593d0ebb'; name = 'S3_Remote'; enabled = $true; url = 's3://example' }

                $result = $apiObject | ConvertTo-XoBackupRepositoryObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.BackupRepository'
            }
        }
    }
}

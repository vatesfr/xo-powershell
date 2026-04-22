BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoRestoreLogObject {
    Context 'When called with a typical API object' {
        It 'Should produce a decorated XoPowershell.RestoreLog object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ id = '1758180544428'; message = 'restore'; status = 'success'; start = 1758180544428; jobId = '33156c65-45e1-431a-bdbb-8c97ae80bd47' }

                $result = ConvertTo-XoRestoreLogObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.RestoreLog'
                $result.RestoreLogId | Should -Be '1758180544428'
                $result.status | Should -Be 'success'
                $result.message | Should -Be 'restore'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ id = '1758180544428'; message = 'restore'; status = 'success'; start = 1758180544428; jobId = '33156c65-45e1-431a-bdbb-8c97ae80bd47' }

                $result = $apiObject | ConvertTo-XoRestoreLogObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.RestoreLog'
            }
        }
    }
}

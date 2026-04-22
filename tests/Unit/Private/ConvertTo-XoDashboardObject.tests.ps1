BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoDashboardObject {
    Context 'When called with a typical API object' {
        It 'Should produce a decorated XoPowershell.Dashboard object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ nPools = 2; nHosts = 5 }

                $result = ConvertTo-XoDashboardObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Dashboard'
                $result.nPools | Should -Be 2
                $result.nHosts | Should -Be 5
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ nPools = 2; nHosts = 5 }

                $result = $apiObject | ConvertTo-XoDashboardObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Dashboard'
            }
        }
    }
}

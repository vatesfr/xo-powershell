BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoPbdObject {
    Context 'When called with a typical API object' {
        It 'Should produce a decorated XoPowershell.Pbd object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ uuid = '16b2a60f-7c4d-f45f-7c7a-963b06fc587d'; id = '16b2a60f-7c4d-f45f-7c7a-963b06fc587d'; attached = $true; host = 'host-1'; SR = 'sr-1' }

                $result = ConvertTo-XoPbdObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Pbd'
                $result.PbdUuid | Should -Be '16b2a60f-7c4d-f45f-7c7a-963b06fc587d'
                $result.attached | Should -BeTrue
                $result.host | Should -Be 'host-1'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ uuid = '16b2a60f-7c4d-f45f-7c7a-963b06fc587d'; id = '16b2a60f-7c4d-f45f-7c7a-963b06fc587d'; attached = $true; host = 'host-1'; SR = 'sr-1' }

                $result = $apiObject | ConvertTo-XoPbdObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Pbd'
            }
        }
    }
}

BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoVmControllerObject {
    Context 'When called with a typical API object' {
        It 'Should produce a decorated XoPowershell.VmController object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ uuid = '9b4775bd-9493-490a-9afa-f786a44caa4f'; name_label = 'dom0'; name_description = 'control domain'; power_state = 'Running'; host = 'b61a5c92-700e-4966-a13b-00633f03eea8' }

                $result = ConvertTo-XoVmControllerObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.VmController'
                $result.VmControllerUuid | Should -Be '9b4775bd-9493-490a-9afa-f786a44caa4f'
                $result.Name | Should -Be 'dom0'
                $result.PowerState | Should -Be 'Running'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ uuid = '9b4775bd-9493-490a-9afa-f786a44caa4f'; name_label = 'dom0'; name_description = 'control domain'; power_state = 'Running'; host = 'b61a5c92-700e-4966-a13b-00633f03eea8' }

                $result = $apiObject | ConvertTo-XoVmControllerObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.VmController'
            }
        }
    }
}

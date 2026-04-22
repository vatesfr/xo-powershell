BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoGuiRouteObject {
    Context 'When called with a typical API object' {
        It 'Should produce a decorated XoPowershell.GuiRoute object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ xo5 = '/'; xo6 = '/v6' }

                $result = ConvertTo-XoGuiRouteObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.GuiRoute'
                $result.xo5 | Should -Be '/'
                $result.xo6 | Should -Be '/v6'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ xo5 = '/'; xo6 = '/v6' }

                $result = $apiObject | ConvertTo-XoGuiRouteObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.GuiRoute'
            }
        }
    }
}

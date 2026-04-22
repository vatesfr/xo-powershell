BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoUserObject {
    Context 'When called with a typical API object' {
        It 'Should produce a decorated XoPowershell.User object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ id = '722d17b9-699b-49d2-8193-be1ac573d3de'; name = 'admin@admin.net'; email = 'admin@admin.net'; permission = 'admin'; groups = @() }

                $result = ConvertTo-XoUserObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.User'
                $result.UserId | Should -Be '722d17b9-699b-49d2-8193-be1ac573d3de'
                $result.Name | Should -Be 'admin@admin.net'
                $result.permission | Should -Be 'admin'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ id = '722d17b9-699b-49d2-8193-be1ac573d3de'; name = 'admin@admin.net'; email = 'admin@admin.net'; permission = 'admin'; groups = @() }

                $result = $apiObject | ConvertTo-XoUserObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.User'
            }
        }
    }
}

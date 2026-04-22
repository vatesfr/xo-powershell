BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoGroupObject {
    Context 'When called with a typical API object' {
        It 'Should produce a decorated XoPowershell.Group object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ id = '7d98fee4-3357-41a7-ac3f-9124212badb7'; name = 'group 1'; users = @('user-1') }

                $result = ConvertTo-XoGroupObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Group'
                $result.GroupId | Should -Be '7d98fee4-3357-41a7-ac3f-9124212badb7'
                $result.Name | Should -Be 'group 1'
                $result.users | Should -Be @('user-1')
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ id = '7d98fee4-3357-41a7-ac3f-9124212badb7'; name = 'group 1'; users = @('user-1') }

                $result = $apiObject | ConvertTo-XoGroupObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Group'
            }
        }
    }
}

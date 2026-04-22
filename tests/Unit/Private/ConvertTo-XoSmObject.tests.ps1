BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoSmObject {
    Context 'When called with a typical API object' {
        It 'Should produce a decorated XoPowershell.Sm object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ uuid = '5bfb2f8a-70f3-8cff-1748-3cd4de2153da'; name_label = 'Local EXT4'; name_description = 'Local ext4 SR'; SM_type = 'ext'; vendor = 'Citrix'; version = '1.0' }

                $result = ConvertTo-XoSmObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Sm'
                $result.SmUuid | Should -Be '5bfb2f8a-70f3-8cff-1748-3cd4de2153da'
                $result.Name | Should -Be 'Local EXT4'
                $result.Description | Should -Be 'Local ext4 SR'
                $result.Type | Should -Be 'ext'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ uuid = '5bfb2f8a-70f3-8cff-1748-3cd4de2153da'; name_label = 'Local EXT4'; name_description = 'Local ext4 SR'; SM_type = 'ext'; vendor = 'Citrix'; version = '1.0' }

                $result = $apiObject | ConvertTo-XoSmObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Sm'
            }
        }
    }
}

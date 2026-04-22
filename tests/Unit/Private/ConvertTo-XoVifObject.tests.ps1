BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoVifObject {
    Context 'When called with a typical VIF API object' {
        It 'Should produce a decorated XoPowershell.Vif object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid             = 'vif-1'
                    name_label       = 'vif-eth0'
                    name_description = 'Primary VIF'
                    MAC              = 'aa:bb:cc:11:22:33'
                    device           = '0'
                    attached         = $true
                }

                $result = ConvertTo-XoVifObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Vif'
                $result.VifUuid | Should -Be 'vif-1'
                $result.Name | Should -Be 'vif-eth0'
                $result.Description | Should -Be 'Primary VIF'
                $result.MAC | Should -Be 'aa:bb:cc:11:22:33'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $result = [pscustomobject]@{ uuid = 'u'; name_label = 'n' } | ConvertTo-XoVifObject

                $result.VifUuid | Should -Be 'u'
                $result.Name | Should -Be 'n'
            }
        }
    }
}

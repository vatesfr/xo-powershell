BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoPifObject {
    Context 'When called with a typical PIF API object' {
        It 'Should produce a decorated XoPowershell.Pif object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid             = 'pif-1'
                    name_label       = 'eth0'
                    name_description = 'Primary NIC'
                    device           = 'eth0'
                    mac              = 'aa:bb:cc:dd:ee:ff'
                }

                $result = ConvertTo-XoPifObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Pif'
                $result.PifUuid | Should -Be 'pif-1'
                $result.Name | Should -Be 'eth0'
                $result.Description | Should -Be 'Primary NIC'
                $result.device | Should -Be 'eth0'
                $result.mac | Should -Be 'aa:bb:cc:dd:ee:ff'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $result = [pscustomobject]@{ uuid = 'u'; name_label = 'n' } | ConvertTo-XoPifObject

                $result.PifUuid | Should -Be 'u'
                $result.Name | Should -Be 'n'
            }
        }
    }
}

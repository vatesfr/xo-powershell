BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoNetworkObject {
    Context 'When called with a typical network API object' {
        It 'Should produce a decorated XoPowershell.Network object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid             = 'net-1'
                    name_label       = 'lan'
                    name_description = 'Primary LAN'
                    PIFs             = @('pif-a', 'pif-b')
                    VIFs             = @('vif-1')
                }

                $result = ConvertTo-XoNetworkObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Network'
                $result.NetworkUuid | Should -Be 'net-1'
                $result.Name | Should -Be 'lan'
                $result.Description | Should -Be 'Primary LAN'
                $result.PifUuid | Should -Be @('pif-a', 'pif-b')
                $result.VifUuid | Should -Be @('vif-1')
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $result = [pscustomobject]@{ uuid = 'u'; name_label = 'n' } | ConvertTo-XoNetworkObject

                $result.NetworkUuid | Should -Be 'u'
                $result.Name | Should -Be 'n'
            }
        }
    }
}

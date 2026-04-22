BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoProxyObject {
    Context 'When called with a typical API object' {
        It 'Should produce a decorated XoPowershell.Proxy object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ id = 'e625ea0c-a876-405a-b838-109d762efe88'; name = 'Proxy1'; vmUuid = 'vm-1'; url = 'https://proxy.example.com'; version = '0.29.29' }

                $result = ConvertTo-XoProxyObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Proxy'
                $result.ProxyId | Should -Be 'e625ea0c-a876-405a-b838-109d762efe88'
                $result.Name | Should -Be 'Proxy1'
                $result.version | Should -Be '0.29.29'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ id = 'e625ea0c-a876-405a-b838-109d762efe88'; name = 'Proxy1'; vmUuid = 'vm-1'; url = 'https://proxy.example.com'; version = '0.29.29' }

                $result = $apiObject | ConvertTo-XoProxyObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Proxy'
            }
        }
    }
}

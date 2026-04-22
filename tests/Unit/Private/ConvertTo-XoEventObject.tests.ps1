BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoEventObject {
    Context 'When called with a typical API object' {
        It 'Should produce a decorated XoPowershell.Event object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ id = 'evt-1'; name = 'connection-lost'; type = 'host' }

                $result = ConvertTo-XoEventObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Event'
                $result.EventId | Should -Be 'evt-1'
                $result.name | Should -Be 'connection-lost'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ id = 'evt-1'; name = 'connection-lost'; type = 'host' }

                $result = $apiObject | ConvertTo-XoEventObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Event'
            }
        }
    }
}

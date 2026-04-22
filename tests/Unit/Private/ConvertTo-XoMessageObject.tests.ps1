BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoMessageObject {
    Context 'When called with a typical message API object' {
        It 'Should produce a decorated XoPowershell.Message object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid = 'msg-1'
                    name = 'VM_STARTED'
                    type = 'informational'
                    time = 1700000000
                    body = 'VM has started'
                }

                $result = ConvertTo-XoMessageObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Message'
                $result.MessageUuid | Should -Be 'msg-1'
                $result.MessageTime | Should -BeOfType ([System.DateTimeOffset])
                $result.MessageTime.ToUnixTimeSeconds() | Should -Be 1700000000
                $result.name | Should -Be 'VM_STARTED'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $result = [pscustomobject]@{ uuid = 'u'; time = 0 } | ConvertTo-XoMessageObject

                $result.MessageUuid | Should -Be 'u'
                $result.MessageTime.ToUnixTimeSeconds() | Should -Be 0
            }
        }
    }
}

BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe Set-XoObject {
    Context 'When called with a TypeName' {
        It 'Should insert the TypeName at the top of the PSTypeName list' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ a = 1 }

                $result = Set-XoObject -InputObject $apiObject -TypeName 'XoPowershell.Demo'

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Demo'
            }
        }
    }

    Context 'When called with a Properties hashtable' {
        It 'Should add each key/value as a note property on the object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ existing = 'value' }
                $props = @{
                    AddedOne = 'one'
                    AddedTwo = 42
                }

                $result = Set-XoObject -InputObject $apiObject -Properties $props

                $result.existing | Should -Be 'value'
                $result.AddedOne | Should -Be 'one'
                $result.AddedTwo | Should -Be 42
                $result.PSObject.Properties.Name | Should -Contain 'AddedOne'
                $result.PSObject.Properties.Name | Should -Contain 'AddedTwo'
            }
        }
    }

    Context 'When called with both TypeName and Properties' {
        It 'Should apply both and preserve the original properties' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ uuid = 'u-1' }

                $result = Set-XoObject -InputObject $apiObject -TypeName 'XoPowershell.Demo' -Properties @{ Label = 'hello' }

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Demo'
                $result.uuid | Should -Be 'u-1'
                $result.Label | Should -Be 'hello'
            }
        }
    }

    Context 'When called with neither TypeName nor Properties' {
        It 'Should return the object unmodified' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ uuid = 'u-2' }
                $originalTypes = @($apiObject.PSObject.TypeNames)

                $result = Set-XoObject -InputObject $apiObject

                $result.uuid | Should -Be 'u-2'
                $result.PSObject.TypeNames | Should -Be $originalTypes
            }
        }
    }

    Context 'When the input is provided through the pipeline' {
        It 'Should decorate the piped object' {
            InModuleScope -ModuleName $dscModuleName {
                $result = [pscustomobject]@{ id = 'abc' } |
                    Set-XoObject -TypeName 'XoPowershell.Piped' -Properties @{ Name = 'piped' }

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Piped'
                $result.id | Should -Be 'abc'
                $result.Name | Should -Be 'piped'
            }
        }
    }

    Context 'When ShouldProcess is declined via -WhatIf' {
        It 'Should not emit an object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ uuid = 'u-3' }

                $result = Set-XoObject -InputObject $apiObject -TypeName 'XoPowershell.Demo' -WhatIf

                $result | Should -BeNullOrEmpty
            }
        }
    }
}

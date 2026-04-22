BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoPoolPatchObject {
    Context 'When called with a typical pool patch API object' {
        It 'Should produce a decorated XoPowershell.PoolPatch object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid      = 'patch-1'
                    changelog = [pscustomobject]@{
                        date        = 1700000000
                        description = 'Security fix for XSA-XYZ'
                    }
                }

                $result = ConvertTo-XoPoolPatchObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.PoolPatch'
                $result.Date | Should -BeOfType ([System.DateTimeOffset])
                $result.Date.ToUnixTimeSeconds() | Should -Be 1700000000
                $result.Description | Should -Be 'Security fix for XSA-XYZ'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid      = 'p'
                    changelog = [pscustomobject]@{ date = 0; description = 'd' }
                }

                $result = $apiObject | ConvertTo-XoPoolPatchObject

                $result.Description | Should -Be 'd'
            }
        }
    }
}

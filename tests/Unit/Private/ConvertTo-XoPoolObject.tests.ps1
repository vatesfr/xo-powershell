BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoPoolObject {
    Context 'When called with a typical pool API object' {
        It 'Should produce a decorated XoPowershell.Pool object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid             = 'pool-1'
                    name_label       = 'primary'
                    name_description = 'Primary pool'
                    platform_version = '8.2.1'
                    HA_enabled       = $true
                    cpus             = [pscustomobject]@{ cores = 16 }
                }

                $result = ConvertTo-XoPoolObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Pool'
                $result.PoolUuid | Should -Be 'pool-1'
                $result.Name | Should -Be 'primary'
                $result.Description | Should -Be 'Primary pool'
                $result.PlatformVersion | Should -Be '8.2.1'
                $result.HAEnabled | Should -BeTrue
                $result.CpuCores | Should -Be 16
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $result = [pscustomobject]@{ uuid = 'u'; name_label = 'n' } | ConvertTo-XoPoolObject

                $result.PoolUuid | Should -Be 'u'
                $result.Name | Should -Be 'n'
            }
        }
    }
}

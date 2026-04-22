BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoVmObject {
    Context 'When the CPU block exposes a "number" value' {
        It 'Should use CPUs.number for the CPUs property' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid             = 'vm-1'
                    name_label       = 'web-01'
                    name_description = 'Web server'
                    power_state      = 'Running'
                    os_version       = [pscustomobject]@{ distro = 'debian' }
                    parent           = 'parent-uuid'
                    CPUs             = [pscustomobject]@{ number = 4; max = 8 }
                }

                $result = ConvertTo-XoVmObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Vm'
                $result.VmUuid | Should -Be 'vm-1'
                $result.Name | Should -Be 'web-01'
                $result.Description | Should -Be 'Web server'
                $result.PowerState | Should -Be 'Running'
                $result.Parent | Should -Be 'parent-uuid'
                $result.CPUs | Should -Be 4
            }
        }
    }

    Context 'When the CPU block only exposes a "max" value' {
        It 'Should fall back to CPUs.max for the CPUs property' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid       = 'vm-2'
                    name_label = 'web-02'
                    CPUs       = [pscustomobject]@{ max = 2 }
                }

                $result = ConvertTo-XoVmObject -InputObject $apiObject

                $result.CPUs | Should -Be 2
            }
        }
    }

    Context 'When the CPU block has neither number nor max' {
        It 'Should set CPUs to $null' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid       = 'vm-3'
                    name_label = 'web-03'
                    CPUs       = [pscustomobject]@{}
                }

                $result = ConvertTo-XoVmObject -InputObject $apiObject

                $result.CPUs | Should -BeNullOrEmpty
            }
        }
    }
}

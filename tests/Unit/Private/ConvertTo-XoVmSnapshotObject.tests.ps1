BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoVmSnapshotObject {
    Context 'When the snapshot has a CPUs.number value' {
        It 'Should produce an XoPowershell.VmSnapshot object with CPUs from number' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid             = 'vm-snap-1'
                    name_label       = 'pre-update'
                    name_description = 'Before update'
                    power_state      = 'Halted'
                    snapshot_of      = 'vm-1'
                    snapshot_time    = 1700000000
                    memory           = 2147483648
                    CPUs             = [pscustomobject]@{ number = 2 }
                }

                $result = ConvertTo-XoVmSnapshotObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.VmSnapshot'
                $result.VmSnapshotUuid | Should -Be 'vm-snap-1'
                $result.Name | Should -Be 'pre-update'
                $result.Description | Should -Be 'Before update'
                $result.PowerState | Should -Be 'Halted'
                $result.SnapshotOf | Should -Be 'vm-1'
                $result.SnapshotTime | Should -BeOfType ([System.DateTimeOffset])
                $result.SnapshotTime.ToUnixTimeSeconds() | Should -Be 1700000000
                $result.Memory | Should -Be 2147483648
                $result.CPUs | Should -Be 2
            }
        }
    }

    Context 'When the snapshot has only CPUs.max' {
        It 'Should fall back to CPUs.max' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid          = 'vm-snap-2'
                    name_label    = 's'
                    snapshot_time = 0
                    CPUs          = [pscustomobject]@{ max = 8 }
                }

                $result = ConvertTo-XoVmSnapshotObject -InputObject $apiObject

                $result.CPUs | Should -Be 8
            }
        }
    }

    Context 'When CPUs is $null' {
        It 'Should not add a CPUs property' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid          = 'vm-snap-3'
                    name_label    = 's'
                    snapshot_time = 0
                    CPUs          = $null
                }

                $result = ConvertTo-XoVmSnapshotObject -InputObject $apiObject

                $result.PSObject.Properties.Name | Should -Not -Contain 'CPUs'
            }
        }
    }
}

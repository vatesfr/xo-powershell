BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoAlarmObject {
    Context 'When called with a typical alarm API object' {
        It 'Should produce a decorated XoPowershell.Alarm object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid = 'a1b2c3d4'
                    type = 'ALARM'
                    time = 1700000000
                    name = 'MyAlarm'
                    body = [pscustomobject]@{
                        name  = 'HIGH_CPU'
                        value = '95%'
                    }
                }

                $result = ConvertTo-XoAlarmObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Alarm'
                $result.BodyName | Should -Be 'HIGH_CPU'
                $result.BodyValue | Should -Be '95%'
                $result.AlarmTime | Should -BeOfType ([System.DateTimeOffset])
                $result.AlarmTime.ToUnixTimeSeconds() | Should -Be 1700000000
                $result.uuid | Should -Be 'a1b2c3d4'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid = 'x'
                    time = 0
                    body = [pscustomobject]@{ name = 'X'; value = 'Y' }
                }

                $result = $apiObject | ConvertTo-XoAlarmObject

                $result.BodyName | Should -Be 'X'
                $result.BodyValue | Should -Be 'Y'
            }
        }
    }
}

BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoScheduleObject {
    Context 'When called with a typical schedule API object' {
        It 'Should produce a decorated XoPowershell.Schedule object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    id       = 'sched-1'
                    name     = 'Nightly backup'
                    cron     = '0 0 * * *'
                    enabled  = $true
                    timezone = 'UTC'
                    jobId    = 'job-42'
                }

                $result = ConvertTo-XoScheduleObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Schedule'
                $result.ScheduleId | Should -Be 'sched-1'
                $result.cron | Should -Be '0 0 * * *'
                $result.enabled | Should -BeTrue
                $result.jobId | Should -Be 'job-42'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $result = [pscustomobject]@{ id = 'x' } | ConvertTo-XoScheduleObject

                $result.ScheduleId | Should -Be 'x'
            }
        }
    }
}

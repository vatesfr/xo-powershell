BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoTaskObject {
    Context 'When the task has name, type, timestamps, progress, and a result message' {
        It 'Should map all fields onto the XoPowershell.Task object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    id         = 'task-1'
                    status     = 'success'
                    progress   = 100
                    start      = 1700000000000
                    end        = 1700000060000
                    properties = [pscustomobject]@{
                        name = 'Snapshot'
                        type = 'VM'
                    }
                    result     = [pscustomobject]@{ message = 'Done' }
                }

                $result = ConvertTo-XoTaskObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Task'
                $result.TaskId | Should -Be 'task-1'
                $result.Name | Should -Be 'Snapshot'
                $result.Type | Should -Be 'VM'
                $result.Status | Should -Be 'success'
                $result.Progress | Should -Be 100
                $result.StartTime | Should -BeOfType ([System.DateTimeOffset])
                $result.StartTime.ToUnixTimeMilliseconds() | Should -Be 1700000000000
                $result.EndTime.ToUnixTimeMilliseconds() | Should -Be 1700000060000
                $result.Message | Should -Be 'Done'
            }
        }
    }

    Context 'When the task has no name but has a method, and no message but has a code' {
        It 'Should fall back to method for Name and code for Message' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    id         = 'task-2'
                    status     = 'failure'
                    properties = [pscustomobject]@{ method = 'vm.start' }
                    result     = [pscustomobject]@{ code = 'HOST_OFFLINE' }
                }

                $result = ConvertTo-XoTaskObject -InputObject $apiObject

                $result.Name | Should -Be 'vm.start'
                $result.Message | Should -Be 'HOST_OFFLINE'
            }
        }
    }

    Context 'When the task has no name, type, timestamps, progress, or result' {
        It 'Should default to the documented fallback values' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    id         = 'task-3'
                    status     = 'pending'
                    properties = [pscustomobject]@{}
                    result     = [pscustomobject]@{}
                    start      = 0
                    end        = 0
                }

                $result = ConvertTo-XoTaskObject -InputObject $apiObject

                $result.Name | Should -Be 'Unknown'
                $result.Type | Should -Be ''
                $result.Progress | Should -Be 0
                $result.StartTime | Should -BeNullOrEmpty
                $result.EndTime | Should -BeNullOrEmpty
                $result.Message | Should -Be ''
            }
        }
    }
}

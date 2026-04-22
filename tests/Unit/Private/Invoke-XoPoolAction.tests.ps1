BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName

    InModuleScope -ModuleName $script:dscModuleName {
        $script:XoHost = 'https://xo.example.com'
        $script:XoRestParameters = @{}
    }
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe Invoke-XoPoolAction {
    Context 'Parameter validation' {
        It 'Should reject actions that are not in the ValidateSet' {
            InModuleScope -ModuleName $dscModuleName {
                { Invoke-XoPoolAction -PoolUuid 'p1' -Action 'not_a_real_action' } |
                    Should -Throw
            }
        }

        It 'Should accept each documented action' -ForEach @(
            @{ Action = 'create_bonded_network';   NeedsParams = $true }
            @{ Action = 'create_internal_network'; NeedsParams = $true }
            @{ Action = 'create_network';          NeedsParams = $true }
            @{ Action = 'create_vm';               NeedsParams = $true }
            @{ Action = 'management_reconfigure';  NeedsParams = $true }
            @{ Action = 'emergency_shutdown';      NeedsParams = $false }
            @{ Action = 'rolling_reboot';          NeedsParams = $false }
            @{ Action = 'rolling_update';          NeedsParams = $false }
        ) {
            InModuleScope -ModuleName $dscModuleName -Parameters @{ Action = $Action; NeedsParams = $NeedsParams } {
                param($Action, $NeedsParams)

                Mock -CommandName Invoke-RestMethod -MockWith { return '/rest/v0/tasks/task-1' }
                Mock -CommandName ConvertFrom-XoTaskHref -MockWith { return [pscustomobject]@{ TaskId = 'task-1' } }

                if ($NeedsParams)
                {
                    { Invoke-XoPoolAction -PoolUuid 'p1' -Action $Action -ActionParameters @{ anything = 1 } } | Should -Not -Throw
                }
                else
                {
                    { Invoke-XoPoolAction -PoolUuid 'p1' -Action $Action } | Should -Not -Throw
                }
            }
        }
    }

    Context 'When an action requires ActionParameters and none are supplied' {
        It 'Should throw a descriptive error' -ForEach @(
            @{ Action = 'create_bonded_network' }
            @{ Action = 'create_internal_network' }
            @{ Action = 'create_network' }
            @{ Action = 'create_vm' }
            @{ Action = 'management_reconfigure' }
        ) {
            InModuleScope -ModuleName $dscModuleName -Parameters @{ Action = $Action } {
                param($Action)

                { Invoke-XoPoolAction -PoolUuid 'p1' -Action $Action } |
                    Should -Throw -ExpectedMessage 'ActionParameters are required*'
            }
        }
    }

    Context 'When a parameterless action is invoked' {
        It 'Should POST to /pools/{id}/actions/<action> and convert the task href' {
            InModuleScope -ModuleName $dscModuleName {
                $script:capturedUri = $null
                $script:capturedMethod = $null
                Mock -CommandName Invoke-RestMethod -MockWith {
                    $script:capturedUri = $Uri
                    $script:capturedMethod = $Method
                    return '/rest/v0/tasks/task-42'
                }
                Mock -CommandName ConvertFrom-XoTaskHref -MockWith {
                    param($Uri)
                    return [pscustomobject]@{ TaskId = 'task-42'; HrefSeen = $Uri }
                }

                $result = Invoke-XoPoolAction -PoolUuid '00000000-0000-0000-0000-000000000001' -Action 'rolling_reboot'

                $script:capturedMethod | Should -Be 'Post'
                $script:capturedUri | Should -Match '/pools/.+/actions/rolling_reboot'
                $result.TaskId | Should -Be 'task-42'
                $result.HrefSeen | Should -Be '/rest/v0/tasks/task-42'
            }
        }

        It 'Should pass sync=true in the URL when -Sync is specified' {
            InModuleScope -ModuleName $dscModuleName {
                $script:capturedUri = $null
                Mock -CommandName Invoke-RestMethod -MockWith {
                    $script:capturedUri = $Uri
                    return '/rest/v0/tasks/t'
                }
                Mock -CommandName ConvertFrom-XoTaskHref -MockWith { return $null }

                $null = Invoke-XoPoolAction -PoolUuid 'p1' -Action 'rolling_update' -Sync

                $script:capturedUri | Should -Match 'sync=true'
            }
        }

        It 'Should pass sync=false in the URL when -Sync is not specified' {
            InModuleScope -ModuleName $dscModuleName {
                $script:capturedUri = $null
                Mock -CommandName Invoke-RestMethod -MockWith {
                    $script:capturedUri = $Uri
                    return '/rest/v0/tasks/t'
                }
                Mock -CommandName ConvertFrom-XoTaskHref -MockWith { return $null }

                $null = Invoke-XoPoolAction -PoolUuid 'p1' -Action 'rolling_reboot'

                $script:capturedUri | Should -Match 'sync=false'
            }
        }
    }
}

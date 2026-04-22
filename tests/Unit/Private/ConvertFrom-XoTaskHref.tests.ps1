BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertFrom-XoTaskHref {
    Context 'When the URL matches the task href pattern' {
        It 'Should extract the task ID and call Get-XoTask with it' {
            InModuleScope -ModuleName $dscModuleName {
                Mock -CommandName Get-XoTask -MockWith { return [pscustomobject]@{ TaskId = $TaskId } }

                $result = ConvertFrom-XoTaskHref -Uri 'https://xo.example.com/rest/v0/tasks/0m8k2zkzi'

                Should -Invoke -CommandName Get-XoTask -Times 1 -Exactly -ParameterFilter { $TaskId -eq '0m8k2zkzi' }
                $result.TaskId | Should -Be '0m8k2zkzi'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                Mock -CommandName Get-XoTask -MockWith { return [pscustomobject]@{ TaskId = $TaskId } }

                $result = '/rest/v0/tasks/abc123' | ConvertFrom-XoTaskHref

                $result.TaskId | Should -Be 'abc123'
            }
        }
    }

    Context 'When the URL does not match the task href pattern' {
        It 'Should throw a descriptive error' {
            InModuleScope -ModuleName $dscModuleName {
                { ConvertFrom-XoTaskHref -Uri 'https://example.com/not-a-task' } |
                    Should -Throw -ExpectedMessage 'Bad task href format*'
            }
        }
    }
}

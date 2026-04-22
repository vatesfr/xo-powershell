BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName

    InModuleScope -ModuleName $script:dscModuleName {
        $script:XoRestParameters = @{}
    }
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe Invoke-XoRestMethod {
    Context 'When the underlying Invoke-RestMethod returns a parsed object' {
        It 'Should return the object unchanged' {
            InModuleScope -ModuleName $dscModuleName {
                Mock -CommandName Invoke-RestMethod -MockWith {
                    return [pscustomobject]@{ hello = 'world' }
                }

                $result = Invoke-XoRestMethod -Uri 'https://xo.example.com/rest/v0/hosts'

                $result.hello | Should -Be 'world'
                Should -Invoke -CommandName Invoke-RestMethod -Times 1 -Exactly
            }
        }
    }

    Context 'When the underlying Invoke-RestMethod returns a JSON string (parser failure)' {
        It 'Should re-parse via -AsHashtable and return a PSCustomObject' {
            InModuleScope -ModuleName $dscModuleName {
                Mock -CommandName Invoke-RestMethod -MockWith {
                    return '{"key":"value","count":3}'
                }

                $result = Invoke-XoRestMethod -Uri 'https://xo.example.com/rest/v0/hosts'

                $result | Should -BeOfType ([pscustomobject])
                $result.key | Should -Be 'value'
                $result.count | Should -Be 3
            }
        }
    }

    Context 'When the Body parameter is provided' {
        It 'Should forward it to the underlying Invoke-RestMethod' {
            InModuleScope -ModuleName $dscModuleName {
                Mock -CommandName Invoke-RestMethod -MockWith { return [pscustomobject]@{ ok = $true } }

                $body = @{ filter = 'power_state:Running' }
                $null = Invoke-XoRestMethod -Uri 'https://xo.example.com/rest/v0/vms' -Body $body

                Should -Invoke -CommandName Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
                    $Body -and $Body.filter -eq 'power_state:Running'
                }
            }
        }
    }
}

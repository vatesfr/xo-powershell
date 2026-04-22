BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertFrom-XoUuidHref {
    BeforeAll {
        InModuleScope -ModuleName $dscModuleName {
            $script:XoHost = 'https://xo.example.com'
        }
    }

    Context 'When the href matches the expected REST pattern' {
        It 'Should return the last URL segment' {
            InModuleScope -ModuleName $dscModuleName {
                $result = ConvertFrom-XoUuidHref -Uri '/rest/v0/pools/011ccf6a-c5ad-48ec-a255-d056584686f0'

                $result | Should -Be '011ccf6a-c5ad-48ec-a255-d056584686f0'
            }
        }

        It 'Should work with an absolute URL' {
            InModuleScope -ModuleName $dscModuleName {
                $result = ConvertFrom-XoUuidHref -Uri 'https://xo.example.com/rest/v0/vms/abc-123'

                $result | Should -Be 'abc-123'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $result = '/rest/v0/hosts/deadbeef' | ConvertFrom-XoUuidHref

                $result | Should -Be 'deadbeef'
            }
        }
    }

    Context 'When the href is malformed' {
        It 'Should throw the "Bad href format" error' {
            InModuleScope -ModuleName $dscModuleName {
                { ConvertFrom-XoUuidHref -Uri '/not/an/api/path' } |
                    Should -Throw -ExpectedMessage 'Bad href format'
            }
        }
    }
}

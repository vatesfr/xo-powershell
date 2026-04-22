BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertFrom-XoSecureString {
    Context 'When called with a SecureString' {
        It 'Should return the original plain-text value' {
            InModuleScope -ModuleName $dscModuleName {
                $plain = 'P@ssw0rd!'
                $secure = ConvertTo-SecureString -String $plain -AsPlainText -Force

                $result = ConvertFrom-XoSecureString -SecureString $secure

                $result | Should -Be $plain
            }
        }

        It 'Should return a single string object' {
            InModuleScope -ModuleName $dscModuleName {
                $secure = ConvertTo-SecureString -String 'abc' -AsPlainText -Force

                $result = ConvertFrom-XoSecureString -SecureString $secure

                ($result | Measure-Object).Count | Should -Be 1
                $result | Should -BeOfType ([string])
            }
        }

        It 'Should return an empty string when the SecureString is empty' {
            InModuleScope -ModuleName $dscModuleName {
                $secure = [securestring]::new()

                $result = ConvertFrom-XoSecureString -SecureString $secure

                $result | Should -Be ''
            }
        }

        It 'Should preserve unicode characters' {
            InModuleScope -ModuleName $dscModuleName {
                $plain = 'пароль-密码-🔐'
                $secure = ConvertTo-SecureString -String $plain -AsPlainText -Force

                $result = ConvertFrom-XoSecureString -SecureString $secure

                $result | Should -Be $plain
            }
        }
    }

    Context 'When the SecureString is provided through the pipeline' {
        It 'Should return the original plain-text value' {
            InModuleScope -ModuleName $dscModuleName {
                $plain = 'piped-secret'
                $secure = ConvertTo-SecureString -String $plain -AsPlainText -Force

                $result = $secure | ConvertFrom-XoSecureString

                $result | Should -Be $plain
            }
        }
    }

    Context 'When a null SecureString is provided' {
        It 'Should throw because the parameter is mandatory' {
            InModuleScope -ModuleName $dscModuleName {
                { ConvertFrom-XoSecureString -SecureString $null } | Should -Throw
            }
        }
    }
}

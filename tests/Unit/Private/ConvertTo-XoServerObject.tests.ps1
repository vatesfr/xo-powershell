BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoServerObject {
    Context 'When called with a typical server API object' {
        It 'Should produce a decorated XoPowershell.Server object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    id                 = 'srv-1'
                    label              = 'primary-xo'
                    host               = 'xo-host-01'
                    address            = '10.0.0.1'
                    status             = 'connected'
                    version            = '5.100.0'
                    enabled            = $true
                    readOnly           = $false
                    username           = 'admin'
                    error              = ''
                    allowUnauthorized  = $false
                }

                $result = ConvertTo-XoServerObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Server'
                $result.ServerUuid | Should -Be 'srv-1'
                $result.Name | Should -Be 'primary-xo'
                $result.NameHost | Should -Be 'xo-host-01'
                $result.Address | Should -Be '10.0.0.1'
                $result.Status | Should -Be 'connected'
                $result.Version | Should -Be '5.100.0'
                $result.Enabled | Should -BeTrue
                $result.ReadOnly | Should -BeFalse
                $result.Username | Should -Be 'admin'
                $result.Error | Should -Be ''
                $result.AllowUnauthorized | Should -BeFalse
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $result = [pscustomobject]@{ id = 'x'; label = 'y' } | ConvertTo-XoServerObject

                $result.ServerUuid | Should -Be 'x'
                $result.Name | Should -Be 'y'
            }
        }
    }
}

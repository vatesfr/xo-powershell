BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoHostObject {
    Context 'When called with a typical host API object' {
        It 'Should produce a decorated XoPowershell.Host object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid             = '812b59e1-2682-43ef-acd4-808d3551b907'
                    name_label       = 'host-01'
                    name_description = 'Primary host'
                    power_state      = 'Running'
                    bios_strings     = [pscustomobject]@{ vendor = 'Acme' }
                    license_params   = [pscustomobject]@{ sku = 'std' }
                    license_server   = 'license.example.com'
                    license_expiry   = 1700000000
                }

                $result = ConvertTo-XoHostObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Host'
                $result.HostUuid | Should -Be '812b59e1-2682-43ef-acd4-808d3551b907'
                $result.Name | Should -Be 'host-01'
                $result.Description | Should -Be 'Primary host'
                $result.PowerState | Should -Be 'Running'
                $result.BiosStrings.vendor | Should -Be 'Acme'
                $result.LicenseParams.sku | Should -Be 'std'
                $result.LicenseServer | Should -Be 'license.example.com'
                $result.LicenseExpiry | Should -Be 1700000000
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid        = 'u'
                    name_label  = 'h'
                    power_state = 'Halted'
                }

                $result = $apiObject | ConvertTo-XoHostObject

                $result.HostUuid | Should -Be 'u'
                $result.PowerState | Should -Be 'Halted'
            }
        }
    }
}

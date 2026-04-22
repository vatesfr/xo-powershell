BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoUserAuthenticationTokenObject {
    Context 'When called with a typical API object' {
        It 'Should produce a decorated XoPowershell.UserAuthenticationToken object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ id = 'LB_DqCNhcmAoyiioNnajySHIYHrWfsIhYSYn3n8FfJA'; user_id = '722d17b9-699b-49d2-8193-be1ac573d3de'; description = 'xo-cli'; created_at = 1754383334192; expiration = 1756975334192 }

                $result = ConvertTo-XoUserAuthenticationTokenObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.UserAuthenticationToken'
                $result.TokenId | Should -Be 'LB_DqCNhcmAoyiioNnajySHIYHrWfsIhYSYn3n8FfJA'
                $result.UserId | Should -Be '722d17b9-699b-49d2-8193-be1ac573d3de'
                $result.description | Should -Be 'xo-cli'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ id = 'LB_DqCNhcmAoyiioNnajySHIYHrWfsIhYSYn3n8FfJA'; user_id = '722d17b9-699b-49d2-8193-be1ac573d3de'; description = 'xo-cli'; created_at = 1754383334192; expiration = 1756975334192 }

                $result = $apiObject | ConvertTo-XoUserAuthenticationTokenObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.UserAuthenticationToken'
            }
        }
    }
}

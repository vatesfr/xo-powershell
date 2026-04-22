BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoVbdObject {
    Context 'When called with a typical VBD API object' {
        It 'Should produce a decorated XoPowershell.Vbd object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid        = 'vbd-1'
                    is_cd_drive = $true
                    read_only   = $false
                    attached    = $true
                    device      = 'xvda'
                }

                $result = ConvertTo-XoVbdObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Vbd'
                $result.VbdUuid | Should -Be 'vbd-1'
                $result.IsCdDrive | Should -BeTrue
                $result.ReadOnly | Should -BeFalse
                $result.attached | Should -BeTrue
                $result.device | Should -Be 'xvda'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $result = [pscustomobject]@{ uuid = 'u'; is_cd_drive = $false; read_only = $true } | ConvertTo-XoVbdObject

                $result.VbdUuid | Should -Be 'u'
                $result.IsCdDrive | Should -BeFalse
                $result.ReadOnly | Should -BeTrue
            }
        }
    }
}

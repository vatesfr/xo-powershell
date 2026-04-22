BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoPgpuObject {
    Context 'When called with a typical API object' {
        It 'Should produce a decorated XoPowershell.Pgpu object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ uuid = '838335fa-ee21-15e1-760a-a37a3a4ef1db'; dom0Access = 'enabled'; gpuGroup = 'grp-1'; host = 'host-1' }

                $result = ConvertTo-XoPgpuObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Pgpu'
                $result.PgpuUuid | Should -Be '838335fa-ee21-15e1-760a-a37a3a4ef1db'
                $result.dom0Access | Should -Be 'enabled'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ uuid = '838335fa-ee21-15e1-760a-a37a3a4ef1db'; dom0Access = 'enabled'; gpuGroup = 'grp-1'; host = 'host-1' }

                $result = $apiObject | ConvertTo-XoPgpuObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Pgpu'
            }
        }
    }
}

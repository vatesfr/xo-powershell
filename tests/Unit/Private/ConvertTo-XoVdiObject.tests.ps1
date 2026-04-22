BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoVdiObject {
    Context 'When called with a typical VDI API object' {
        It 'Should produce an XoPowershell.Vdi object with renamed fields' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid           = 'vdi-1'
                    name_label     = 'root-disk'
                    content_type   = 'user'
                    size           = 10737418240
                    usage          = 5368709120
                    physical_usage = 4294967296
                    sr_uuid        = 'sr-1'
                    sr_usage       = 8589934592
                }

                $result = ConvertTo-XoVdiObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Vdi'
                $result.VdiUuid | Should -Be 'vdi-1'
                $result.Name | Should -Be 'root-disk'
                $result.ContentType | Should -Be 'user'
                $result.Size | Should -Be 10737418240
                $result.Usage | Should -Be 5368709120
                $result.PhysicalUsage | Should -Be 4294967296
                $result.SrUuid | Should -Be 'sr-1'
                $result.SrUsage | Should -Be 8589934592
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $result = [pscustomobject]@{ uuid = 'u'; name_label = 'n' } | ConvertTo-XoVdiObject

                $result.VdiUuid | Should -Be 'u'
                $result.Name | Should -Be 'n'
            }
        }
    }
}

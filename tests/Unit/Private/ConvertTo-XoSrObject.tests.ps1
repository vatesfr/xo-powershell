BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoSrObject {
    Context 'When called with a typical SR API object' {
        It 'Should produce a decorated XoPowershell.Sr object with formatted sizes' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid           = 'sr-1'
                    name_label     = 'local-storage'
                    SR_type        = 'lvm'
                    content_type   = 'user'
                    size           = 2147483648   # 2 GB
                    usage          = 2097152      # 2 MB
                    physical_usage = 2048         # 2 KB
                }

                $result = ConvertTo-XoSrObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Sr'
                $result.SrUuid | Should -Be 'sr-1'
                $result.Name | Should -Be 'local-storage'
                $result.Type | Should -Be 'lvm'
                $result.ContentType | Should -Be 'user'
                $result.SrSize | Should -Be '2.0 GB'
                $result.UsageSize | Should -Be '2.0 MB'
                $result.PhysicalUsageSize | Should -Be '2.0 KB'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid           = 'u'
                    name_label     = 'n'
                    SR_type        = 'ext'
                    content_type   = 'user'
                    size           = 0
                    usage          = 0
                    physical_usage = 0
                }

                $result = $apiObject | ConvertTo-XoSrObject

                $result.SrUuid | Should -Be 'u'
                $result.SrSize | Should -Be '0.0  B'
            }
        }
    }
}

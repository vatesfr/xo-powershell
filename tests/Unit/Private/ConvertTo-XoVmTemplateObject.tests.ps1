BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoVmTemplateObject {
    Context 'When the template has CPUs.number' {
        It 'Should produce an XoPowershell.VmTemplate object using CPUs.number' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid             = 'tpl-1'
                    name_label       = 'Ubuntu-22.04-Template'
                    name_description = 'Default Ubuntu template'
                    os_version       = [pscustomobject]@{ name = 'ubuntu' }
                    parent           = 'parent-uuid'
                    CPUs             = [pscustomobject]@{ number = 2; max = 4 }
                }

                $result = ConvertTo-XoVmTemplateObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.VmTemplate'
                $result.VmTemplateUuid | Should -Be 'tpl-1'
                $result.Name | Should -Be 'Ubuntu-22.04-Template'
                $result.Description | Should -Be 'Default Ubuntu template'
                $result.Parent | Should -Be 'parent-uuid'
                $result.CPUs | Should -Be 2
            }
        }
    }

    Context 'When the template has only CPUs.max' {
        It 'Should fall back to CPUs.max' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid       = 'tpl-2'
                    name_label = 't'
                    CPUs       = [pscustomobject]@{ max = 8 }
                }

                $result = ConvertTo-XoVmTemplateObject -InputObject $apiObject

                $result.CPUs | Should -Be 8
            }
        }
    }

    Context 'When the template has neither CPUs.number nor CPUs.max' {
        It 'Should set CPUs to $null' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid       = 'tpl-3'
                    name_label = 't'
                    CPUs       = [pscustomobject]@{}
                }

                $result = ConvertTo-XoVmTemplateObject -InputObject $apiObject

                $result.CPUs | Should -BeNullOrEmpty
            }
        }
    }
}

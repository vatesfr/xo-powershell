BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoPciObject {
    Context 'When called with a typical API object' {
        It 'Should produce a decorated XoPowershell.Pci object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ uuid = '9377b642-cc71-8749-1e71-308898b652da'; class_name = 'NVMe'; device_name = 'XG5 SSD'; pci_id = '0000:0d:00.0' }

                $result = ConvertTo-XoPciObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Pci'
                $result.PciUuid | Should -Be '9377b642-cc71-8749-1e71-308898b652da'
                $result.device_name | Should -Be 'XG5 SSD'
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{ uuid = '9377b642-cc71-8749-1e71-308898b652da'; class_name = 'NVMe'; device_name = 'XG5 SSD'; pci_id = '0000:0d:00.0' }

                $result = $apiObject | ConvertTo-XoPciObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Pci'
            }
        }
    }
}

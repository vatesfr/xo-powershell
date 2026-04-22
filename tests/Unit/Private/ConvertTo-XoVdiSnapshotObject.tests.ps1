BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoVdiSnapshotObject {
    Context 'When called with a typical VDI snapshot API object' {
        It 'Should produce an XoPowershell.VdiSnapshot object' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    uuid          = 'vdi-snap-1'
                    name_label    = 'daily-backup'
                    size          = 10737418240
                    snapshot_of   = 'vdi-1'
                    snapshot_time = 1700000000
                    sr_uuid       = 'sr-1'
                    usage         = 5368709120
                }

                $result = ConvertTo-XoVdiSnapshotObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.VdiSnapshot'
                $result.VdiSnapshotUuid | Should -Be 'vdi-snap-1'
                $result.Name | Should -Be 'daily-backup'
                $result.Size | Should -Be 10737418240
                $result.SnapshotOf | Should -Be 'vdi-1'
                $result.SnapshotTime | Should -Be 1700000000
                $result.SrUuid | Should -Be 'sr-1'
                $result.Usage | Should -Be 5368709120
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $result = [pscustomobject]@{ uuid = 'u'; name_label = 'n' } | ConvertTo-XoVdiSnapshotObject

                $result.VdiSnapshotUuid | Should -Be 'u'
                $result.Name | Should -Be 'n'
            }
        }
    }
}

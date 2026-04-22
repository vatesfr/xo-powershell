BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe ConvertTo-XoStatObject {
    Context 'When called with a typical stats payload' {
        It 'Should tag the object as XoPowershell.Stat without changing its shape' {
            InModuleScope -ModuleName $dscModuleName {
                $apiObject = [pscustomobject]@{
                    endTimestamp = 1740158005
                    interval     = 5
                    stats        = [pscustomobject]@{ cpus = @(0.1, 0.2, 0.3) }
                }

                $result = ConvertTo-XoStatObject -InputObject $apiObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Stat'
                $result.endTimestamp | Should -Be 1740158005
                $result.interval | Should -Be 5
                $result.stats.cpus | Should -Be @(0.1, 0.2, 0.3)
            }
        }

        It 'Should accept pipeline input' {
            InModuleScope -ModuleName $dscModuleName {
                $result = [pscustomobject]@{ interval = 60 } | ConvertTo-XoStatObject

                $result.PSObject.TypeNames[0] | Should -Be 'XoPowershell.Stat'
                $result.interval | Should -Be 60
            }
        }
    }
}

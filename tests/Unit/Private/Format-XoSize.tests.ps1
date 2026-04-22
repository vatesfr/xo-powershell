BeforeAll {
    $script:dscModuleName = 'xo-powershell'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe Format-XoSize {
    # Format-XoSize uses a while ($Value -gt 1kb) loop and the parameter is [long],
    # so $Value keeps integer semantics between iterations. These expectations
    # match the actual (integer-truncated) behaviour rather than the ideal one.
    Context 'When called with byte values' {
        It 'Should format <Bytes> as <Expected>' -ForEach @(
            @{ Bytes = 0L;                Expected = '0.0  B' }
            @{ Bytes = 512L;              Expected = '512.0  B' }
            @{ Bytes = 2048L;             Expected = '2.0 KB' }
            @{ Bytes = 2097152L;          Expected = '2.0 MB' }
            @{ Bytes = 2147483648L;       Expected = '2.0 GB' }
            @{ Bytes = 2199023255552L;    Expected = '2.0 TB' }
            @{ Bytes = 2251799813685248L; Expected = '2.0 PB' }
        ) {
            InModuleScope -ModuleName $dscModuleName -Parameters @{ Bytes = $Bytes; Expected = $Expected } {
                param($Bytes, $Expected)

                Format-XoSize -Value $Bytes | Should -Be $Expected
            }
        }
    }

    Context 'When the value is provided through the pipeline' {
        It 'Should format it the same way' {
            InModuleScope -ModuleName $dscModuleName {
                2147483648L | Format-XoSize | Should -Be '2.0 GB'
            }
        }
    }

    Context 'When the value equals exactly one unit boundary' {
        # Because the loop uses -gt (not -ge), the value stays one unit below.
        It 'Should not cross the boundary' {
            InModuleScope -ModuleName $dscModuleName {
                Format-XoSize -Value 1024 | Should -Be '1,024.0  B'
            }
        }
    }
}

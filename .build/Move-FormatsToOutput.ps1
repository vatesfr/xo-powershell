param
(
    [Parameter()]
    [System.String]
    $ProjectName = (property ProjectName ''),

    [Parameter()]
    [System.String]
    $SourcePath = (property SourcePath ''),

    [Parameter()]
    [System.String]
    $OutputDirectory = (property OutputDirectory (Join-Path $BuildRoot 'output')),

    [Parameter()]
    [System.String]
    $BuiltModuleSubdirectory = (property BuiltModuleSubdirectory ''),

    [Parameter()]
    [System.Management.Automation.SwitchParameter]
    $VersionedOutputDirectory = (property VersionedOutputDirectory $true),

    [Parameter()]
    [System.String]
    $BuildModuleOutput = (property BuildModuleOutput (Join-Path $OutputDirectory $BuiltModuleSubdirectory)),

    [Parameter()]
    [System.String]
    $ReleaseNotesPath = (property ReleaseNotesPath (Join-Path $OutputDirectory 'ReleaseNotes.md')),

    [Parameter()]
    [System.String]
    $ModuleVersion = (property ModuleVersion ''),

    [Parameter()]
    [System.Collections.Hashtable]
    $BuildInfo = (property BuildInfo @{ })
)

task Move_Formats_To_Output {
    $ErrorActionPreference = 'Stop'
    $Script:psd = Get-ChildItem -Path "$($BuildRoot)/src" -include *.psd1 -File -Force -Recurse
    $Script:ModuleInfo = Invoke-Expression "$(Get-Content $psd.FullName |Out-string)"
    $Script:ModuleName = $psd.BaseName
    $Script:ModuleDir = Join-Path "$($BuildModuleOutput)" -ChildPath $ModuleName -AdditionalChildPath  $ModuleInfo.ModuleVersion
    $formatsPath = Join-Path -Path $BuildRoot -ChildPath "src" -AdditionalChildPath "formats"
    if (Test-Path $formatsPath)
    {
        try
        {

            $null = Copy-Item -Path $formatsPath -Destination $Script:ModuleDir -Recurse -Force
        }
        catch
        {
            throw $_.Exception.Message
        }
    }
    else
    {
        throw "Unable to find '$($formatsPath)'"
    }

    if (-not (Test-Path $(Join-Path $Script:ModuleDir "formats")))
    {
        throw "Formats folder was not copied to '$($Script:ModuleDir)'"
    }
}

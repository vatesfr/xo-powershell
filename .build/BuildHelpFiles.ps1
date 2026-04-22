param
(
    [Parameter()]
    [string]
    $OutputDirectory = (property OutputDirectory (Join-Path $BuildRoot 'output'))
)
begin
{

}
process
{
    task 'BuildHelpFiles' {
        $Script:OutputDirectory = Get-SamplerAbsolutePath -Path $OutputDirectory -RelativeTo $BuildRoot
        $Script:psd = Get-ChildItem -Path "$($BuildRoot)/src" -include *.psd1 -File -Force -Recurse
        $Script:ModuleInfo = Invoke-Expression "$(Get-Content $psd.FullName |Out-string)"
        $Script:ModuleName = $psd.BaseName
        $Script:ModuleDir = Join-Path "$($OutputDirectory)" -ChildPath "module" -AdditionalChildPath $ModuleName, $ModuleInfo.ModuleVersion
        $Script:help = Join-Path $ModuleDir 'en-US'
        $Script:docs = Join-Path $BuildRoot "docs"
        $Script:index = $(Join-Path $docs "index.md")
        Write-Build Magenta "Creating External Help"
        if (Test-Path $help)
        {
            $null = Remove-Item $help -Recurse -Force
        }
        if (Test-Path $index)
        {
            $null = Remove-Item -Path $index -Force
        }
        Import-Module $(Join-Path $ModuleDir "$($ModuleName).psd1") -Force

        New-MarkdownHelp -Module $ModuleName -OutputFolder $docs -Force
    }
}

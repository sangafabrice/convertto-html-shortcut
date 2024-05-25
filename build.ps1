using namespace 'System.IO'

Filter Get-ModuleInstallationRoot {
    [CmdletBinding()]
    Param(
        [string] $ModuleName = 'MarkdownToHtmlShortcut'
    )
    @((Get-Module -Name $ModuleName -ListAvailable)?.ModuleBase)[0]
}

Filter Get-ModuleInstallationVersion {
    [CmdletBinding()]
    Param(
        [string] $ModuleName = 'MarkdownToHtmlShortcut'
    )
    @((Get-Module -Name $ModuleName -ListAvailable)?.Version)[0]
}

Filter New-ModuleInstallationManifest {
    [CmdletBinding()]
    Param(
        [string] $Path = $PSScriptRoot,
        [string] $ProjectUri = (git ls-remote --get-url) -replace '\.git$',
        [string] $ModuleName = 'MarkdownToHtmlShortcut'
    )
    $VerboseFlag = $VerbosePreference -ine 'SilentlyContinue'
    Try {
        # Read the latest version and the release notes from the latest.json file
        $LatestJson = Get-Content "$Path\latest.json" -Raw -ErrorAction Stop -Verbose:$VerboseFlag | ConvertFrom-Json
        $RootModule = "$ModuleName.psm1"
        @{
            # Arguments built for New-ModuleManifest
            Path = "$Path\$ModuleName.psd1"
            RootModule = $RootModule
            ModuleVersion = $LatestJson.version
            GUID = 'aa021dfd-5cae-4a30-a6fd-325bdc33be82'
            Author = 'Fabrice Sanga'
            CompanyName = 'sangafabrice'
            Copyright = "© $((Get-Date).Year) SangaFabrice. All rights reserved."
            Description = @"
MarkdownToHtmlShortcut helps configure the context menu shortcut that converts Markdown files to HTML files. The module packages functions to add and remove the shortcut on the .md files right-click context menu. 
Note that it does not require administrators' privileges to run.
→ To support this project, please visit and like: $ProjectUri
"@
            PowerShellVersion = '6.1'
            PowerShellHostVersion = '6.1'
            FunctionsToExport = @((Get-Content "$Path\$RootModule").Where{ $_ -like 'Function*' -or $_ -like 'Filter*' }.ForEach{ ($_ -split ' ')[1] })
            CmdletsToExport = @()
            VariablesToExport = @()
            AliasesToExport = @()
            FileList = @(
                "$ModuleName.psd1"
                Get-ChildItem -Recurse -Include '*MarkdownToHtml*.*','*.ico' -File -Name
            )
            Tags = @('context-menu-shortcut','windows-registry')
            LicenseUri = "$ProjectUri/blob/main/LICENSE"
            ProjectUri = $ProjectUri
            IconUri = 'https://rawcdn.githack.com/sangafabrice/convertto-html-shortcut/9a108e22c01cde6c064240fed68e3f7eefede8ea/module-icon.svg'
            ReleaseNotes = $LatestJson.releaseNotes -join "`n"
        }.ForEach{
            New-ModuleManifest @_ -ErrorAction Stop -Verbose:$VerboseFlag
            [Path]::GetFullPath($_.Path)
        }
    }
    Catch { Return $_ }
}

@{
    Name = 'ModuleBuilder'
    Scriptblock = ([scriptblock]::Create((Invoke-RestMethod 'https://api.github.com/gists/387cc6063e148917a2fe5503e57b823c').files.'ModuleBuilder.psm1'.content)).GetNewClosure()
} | ForEach-Object { New-Module @_ } | Import-Module -Force
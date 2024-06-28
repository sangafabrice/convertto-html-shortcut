#Requires -Version 6.1

If (-not $IsWindows) {
  Throw 'Windows platform required. The script can only be executed in a Windows OS.'
}

Function Set-MarkdownToHtmlShortcut {
  <#
  .SYNOPSIS
  Install the context menu shortcut to convert Markdown files to HTML files.
  .DESCRIPTION
  This function creates a context menu shortcut to convert Markdown files to HTML files by setting up the Windows Registry.
  #>
  [CmdletBinding()]
  Param ()

  # The arguments to Set-Item and New-Item cmdlets.
  $Arguments = @{
    # The registry key of the command executed by the shortcut.
    Path = 'HKCU:\SOFTWARE\Classes\SystemFileAssociations\.md\shell\ConvertToHtml\Command'
    # %1 is the path to the selected mardown file to convert.
    Value = 'wscript.exe //e:jscript "{0}\Convert-MarkdownToHtml.js" /MarkdownFilePath:"%1"' -f $PSScriptRoot
  }
  # Overwrite the key value if it already exists.
  # Otherwise, create it.
  If (Test-Path $Arguments.Path -PathType Container) {
    Set-Item @Arguments
    $CommandKey = Get-Item $Arguments.Path
  } Else {
    $CommandKey = New-Item @Arguments -Force
  }
  # Set the text on the menu using the parent of the command key: ConvertToHtml.
  Set-Item -Path $CommandKey.PSParentPath -Value 'Convert to &HTML' -Force
}

Set-Alias Install-MarkdownToHtmlShortcut Set-MarkdownToHtmlShortcut

Function Remove-MarkdownToHtmlShortcut {
  <#
  .SYNOPSIS
  Remove the context menu shortcut to convert Markdown files to HTML files.
  .DESCRIPTION
  This function removes the context menu shortcut to convert Markdown files to HTML files by setting up the Windows Registry.
  #>
  [CmdletBinding()]
  Param ()

  # Remove the registry key of the shortcut verb.
  Remove-Item 'HKCU:\SOFTWARE\Classes\SystemFileAssociations\.md\shell\ConvertToHtml' -Recurse
}
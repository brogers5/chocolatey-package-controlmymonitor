$ErrorActionPreference = 'Stop'

$programsDirectory = [Environment]::GetFolderPath([Environment+SpecialFolder]::Programs)
$desktopDirectory = [Environment]::GetFolderPath([Environment+SpecialFolder]::DesktopDirectory)
$linkName = 'ControlMyMonitor.lnk'

$programsShortcutFilePath = Join-Path -Path $programsDirectory -ChildPath $linkName
$desktopShortcutFilePath = Join-Path -Path $desktopDirectory -ChildPath $linkName

if (Test-Path -Path $programsShortcutFilePath) {
    Remove-Item -Path $programsShortcutFilePath -Force
}

if (Test-Path -Path $desktopShortcutFilePath) {
    Remove-Item -Path $desktopShortcutFilePath -Force
}

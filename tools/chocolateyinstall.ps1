$ErrorActionPreference = 'Stop'

$toolsDirectory = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$archiveFilePath = Join-Path -Path $toolsDirectory -ChildPath 'controlmymonitor.zip'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $toolsDirectory
  file          = $archiveFilePath
}
Get-ChocolateyUnzip @packageArgs

#Clean up ZIP archive post-extraction to prevent unnecessary disk bloat
Remove-Item -Path $archiveFilePath -Force -ErrorAction SilentlyContinue

$softwareName = 'ControlMyMonitor'

#Create Start Menu shortcut
$programsDirectory = [Environment]::GetFolderPath([Environment+SpecialFolder]::Programs)
$shortcutFilePath = Join-Path -Path $programsDirectory -ChildPath "$softwareName.lnk"
$targetPath = Join-Path -Path $toolsDirectory -ChildPath 'ControlMyMonitor.exe'
Install-ChocolateyShortcut -ShortcutFilePath $shortcutFilePath -TargetPath $targetPath -ErrorAction SilentlyContinue

$pp = Get-PackageParameters
if ($pp.Start) {
  try {
    Start-Process -FilePath $targetPath -ErrorAction Continue
  }
  catch {
    Write-Warning "$softwareName failed to start, please try to manually start it instead."
  }
}

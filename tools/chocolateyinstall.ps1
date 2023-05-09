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
$binaryFileName = "$softwareName.exe"
$linkName = "$softwareName.lnk"
$targetPath = Join-Path -Path $toolsDirectory -ChildPath $binaryFileName

$pp = Get-PackageParameters
if ($pp.NoShim) {
  #Create shim ignore file
  $ignoreFilePath = Join-Path -Path $toolsDirectory -ChildPath "$binaryFileName.ignore"
  Set-Content -Path $ignoreFilePath -Value $null -ErrorAction SilentlyContinue
}
else {
  #Create GUI shim
  $guiShimPath = Join-Path -Path $toolsDirectory -ChildPath "$binaryFileName.gui"
  Set-Content -Path $guiShimPath -Value $null -ErrorAction SilentlyContinue
}

if (!$pp.NoProgramsShortcut) {
  $programsDirectory = [Environment]::GetFolderPath([Environment+SpecialFolder]::Programs)
  $shortcutFilePath = Join-Path -Path $programsDirectory -ChildPath $linkName
  Install-ChocolateyShortcut -ShortcutFilePath $shortcutFilePath -TargetPath $targetPath -ErrorAction SilentlyContinue
}

if ($pp.Start) {
  try {
    Start-Process -FilePath $targetPath -ErrorAction Continue
  }
  catch {
    Write-Warning "$softwareName failed to start, please try to manually start it instead."
  }
}

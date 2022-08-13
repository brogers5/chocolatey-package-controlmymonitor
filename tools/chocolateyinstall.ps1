$ErrorActionPreference = 'Stop'; # stop on all errors

$packageName = 'controlmymonitor'
$url = 'https://www.nirsoft.net/utils/controlmymonitor.zip'
$checksum = 'f740f305e278668e8580ccfc3c458bbb1106cabd223fab31f8680c58cb9bc79c'
$checksumType = 'SHA256'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

Install-ChocolateyZipPackage -PackageName "$packageName" `
                             -Url "$url" `
                             -UnzipLocation "$toolsDir" `
                             -Checksum "$checksum" `
                             -ChecksumType "$checksumType"

$softwareName = 'ControlMyMonitor'

#Create Start Menu shortcut
$programsDirectory = [Environment]::GetFolderPath([Environment+SpecialFolder]::Programs)
$shortcutFilePath = Join-Path -Path $programsDirectory -ChildPath "$softwareName.lnk"
$targetPath = Join-Path -Path $toolsDir -ChildPath 'ControlMyMonitor.exe'
Install-ChocolateyShortcut -ShortcutFilePath $shortcutFilePath -TargetPath $targetPath -ErrorAction SilentlyContinue

$pp = Get-PackageParameters
if ($pp.Start)
{
  try
  {
    Start-Process -FilePath $targetPath -ErrorAction Continue
  }
  catch
  {
    Write-Warning "$softwareName failed to start, please try to manually start it instead."
  }
}

$ErrorActionPreference = 'Stop'; # stop on all errors

$packageName = 'controlmymonitor'
$url = 'https://www.nirsoft.net/utils/controlmymonitor.zip'
$checksum = 'f740f305e278668e8580ccfc3c458bbb1106cabd223fab31f8680c58cb9bc79c'
$checksumType = 'SHA256'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$installFile = Join-Path $toolsDir "$($packageName).exe"

Install-ChocolateyZipPackage -PackageName "$packageName" `
                             -Url "$url" `
                             -UnzipLocation "$toolsDir" `
                             -Checksum "$checksum" `
                             -ChecksumType "$checksumType"

Set-Content -Path ("$installFile.gui") `
            -Value $null

$ErrorActionPreference = 'Stop'; # stop on all errors

$packageName = 'controlmymonitor'
$url = 'https://www.nirsoft.net/utils/controlmymonitor.zip'
$checksum = 'b81509b058acbe221e0e189565d050354f7a82a4f719872496fd7adf575675dd'
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

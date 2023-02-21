Import-Module au

$currentPath = (Split-Path $MyInvocation.MyCommand.Definition)
$toolsPath = Join-Path -Path $currentPath -ChildPath 'tools'

$projectUri = 'https://www.nirsoft.net/utils/control_my_monitor.html'
$checksumsUrl = 'https://www.nirsoft.net/hash_check/?software=controlmymonitor'
$userAgent = 'Update checker of Chocolatey Community Package ''controlmymonitor'''

function Add-ArchivedUrls {
    $seleniumModuleName = 'Selenium'
    if (!(Get-Module -ListAvailable -Name $seleniumModuleName))
    {
        Install-Module -Name $seleniumModuleName
    }
    Import-Module $seleniumModuleName

    if (!(Test-Path -Path "$env:PROGRAMFILES\Mozilla Firefox\firefox.exe"))
    {
        choco install firefox -y
    }

    $checksumsArchiveUrl = "https://web.archive.org/save/$checksumsUrl"
    Write-Host "Starting Selenium at $checksumsArchiveUrl"
    $seleniumDriver = Start-SeFirefox -StartURL $checksumsArchiveUrl -Headless
    $Latest.ArchivedChecksumsURL = $seleniumDriver.Url
    $seleniumDriver.Dispose()

    $downloadUrl = "https://web.archive.org/save/$($Latest.Url32)"
    Write-Host "Starting Selenium at $downloadUrl"
    $seleniumDriver = Start-SeFirefox $downloadUrl -Headless
    $Latest.ArchivedDownloadURL = $seleniumDriver.Url
    $Latest.DirectArchivedDownloadURL = $Latest.ArchivedDownloadURL -replace '(\d{14})/',"`$1if_/"
    $seleniumDriver.Dispose()
}

function Read-ExpectedChecksums {
    $checksumsResponse = Invoke-WebRequest -Uri $checksumsUrl -UserAgent $userAgent -UseBasicParsing

    $Latest.ExpectedChecksumMD5 = [Regex]::Matches($checksumsResponse.Content, '\b[a-f0-9]{32}\b').Groups[0].Value
    $Latest.ExpectedChecksumSHA1 = [Regex]::Matches($checksumsResponse.Content, '\b[a-f0-9]{40}\b').Groups[0].Value
    $Latest.ExpectedChecksumSHA256 = [Regex]::Matches($checksumsResponse.Content, '\b[a-f0-9]{64}\b').Groups[0].Value
    $Latest.ExpectedChecksumSHA512 = [Regex]::Matches($checksumsResponse.Content, '\b[a-f0-9]{128}\b').Groups[0].Value
}

function Confirm-Checksum($FilePath, $Algorithm, $ExpectedHash) {
    $hash = (Get-FileHash -Path $FilePath -Algorithm $Algorithm).Hash
    if ($ExpectedHash -ne $hash)
    {
        throw "$Algorithm checksum mismatch! Expected '$ExpectedHash', actual is '$hash'"
    }
}

function Confirm-Checksums {
    $filePath = Join-Path -Path $toolsPath -ChildPath $Latest.FileName32

    Confirm-Checksum -FilePath $filePath -Algorithm 'MD5' -ExpectedHash $Latest.ExpectedChecksumMD5
    Confirm-Checksum -FilePath $filePath -Algorithm 'SHA1' -ExpectedHash $Latest.ExpectedChecksumSHA1
    Confirm-Checksum -FilePath $filePath -Algorithm 'SHA256' -ExpectedHash $Latest.ExpectedChecksumSHA256
    Confirm-Checksum -FilePath $filePath -Algorithm 'SHA512' -ExpectedHash $Latest.ExpectedChecksumSHA512
}

function global:au_BeforeUpdate ($Package) {
    Read-ExpectedChecksums
    Get-RemoteFiles -Purge -NoSuffix
    Confirm-Checksums

    Add-ArchivedUrls

    Copy-Item -Path "$toolsPath\VERIFICATION.txt.template" -Destination "$toolsPath\VERIFICATION.txt" -Force

    Set-DescriptionFromReadme -Package $Package -ReadmePath '.\DESCRIPTION.md'
}

function global:au_AfterUpdate ($Package)  {
    $rawLicense = [Regex]::Matches($response.Content, '<h4 class="utilsubject">License<\/h4>\n((.*\n){1,6})').Groups[1].Value
    $processedLicense = $rawLicense.Replace("`n", "`r`n")
    $rawDisclaimer = [Regex]::Matches($response.Content, '<h4 class="utilsubject">Disclaimer<\/h4>\n((.*\n){1,4})').Groups[1].Value
    $processedDisclaimer = ([System.Web.HttpUtility]::HtmlDecode($rawDisclaimer)).Replace("`n", "`r`n")

    Set-Content -Path 'tools\LICENSE.txt' -Value "From: $projectUri`r`n`r`nLicense`r`n`r`n$($processedLicense)`r`nDisclaimer`r`n`r`n$($processedDisclaimer)" -NoNewline
}

function global:au_SearchReplace {
    @{
        'build.ps1' = @{
            '(^\s*Url32\s*=\s*)(''.*'')' = "`$1'$($Latest.DirectArchivedDownloadURL)'"
        }
        "$($Latest.PackageName).nuspec" = @{
            "<packageSourceUrl>[^<]*</packageSourceUrl>" = "<packageSourceUrl>https://github.com/brogers5/chocolatey-package-$($Latest.PackageName)/tree/v$($Latest.Version)</packageSourceUrl>"
            "<copyright>[^<]*</copyright>" = "<copyright>Copyright (c) 2017-$(Get-Date -Format yyyy) Nir Sofer</copyright>"
        }
        'tools\VERIFICATION.txt' = @{
            '%archivedDownloadUrl%' = "$($Latest.ArchivedDownloadURL)"
            '%archivedChecksumsUrl%' = "$($Latest.ArchivedChecksumsURL)"
            '%md5Hash%' = "$($Latest.ExpectedChecksumMD5)"
            '%sha1Hash%' = "$($Latest.ExpectedChecksumSHA1)"
            '%sha256Hash%' = "$($Latest.ExpectedChecksumSHA256)"
            '%sha512Hash%' = "$($Latest.ExpectedChecksumSHA512)"
        }
    }
}

function global:au_GetLatest {
    $script:response = Invoke-WebRequest -Uri $projectUri -UserAgent $userAgent -UseBasicParsing

    $version = [Regex]::Matches($response.Content, '<td>ControlMyMonitor v(\d+(\.\d+){1,3})').Groups[1].Value

    return @{
        Url32 = 'https://www.nirsoft.net/utils/controlmymonitor.zip'
        Version = $version
    }
}

Update-Package -ChecksumFor None -NoReadme

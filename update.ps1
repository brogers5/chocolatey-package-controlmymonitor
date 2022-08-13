Import-Module au

$currentPath = (Split-Path $MyInvocation.MyCommand.Definition)
$toolsPath = Join-Path -Path $currentPath -ChildPath 'tools'

$projectUri = 'https://www.nirsoft.net/utils/control_my_monitor.html'

function global:au_BeforeUpdate ($Package)  {
    Get-RemoteFiles -Purge -NoSuffix -Algorithm sha256

    if (!(Test-Path -Path "$env:PROGRAMFILES\Mozilla Firefox\firefox.exe"))
    {
        choco install firefox -y
    }

    $seleniumModuleName = 'Selenium'
    if (!(Get-Module -ListAvailable -Name $seleniumModuleName))
    {
        Install-Module -Name $seleniumModuleName
    }
    Import-Module $seleniumModuleName

    $startUrl = "https://web.archive.org/save/$($Latest.Url32)"
    Write-Host "Starting Selenium at $startUrl"
    $seleniumDriver = Start-SeFirefox -StartURL $startUrl -Headless
    $Latest.ArchivedURL = $seleniumDriver.Url
    $seleniumDriver.Dispose()

    Copy-Item -Path "$toolsPath\VERIFICATION.txt.template" -Destination "$toolsPath\VERIFICATION.txt" -Force

    Set-DescriptionFromReadme -Package $Package -ReadmePath ".\DESCRIPTION.md"
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
            '(^\s*Url32\s*=\s*)(''.*'')' = "`$1'$($Latest.ArchivedURL)'"
        }
        "$($Latest.PackageName).nuspec" = @{
            "<packageSourceUrl>[^<]*</packageSourceUrl>" = "<packageSourceUrl>https://github.com/brogers5/chocolatey-package-$($Latest.PackageName)/tree/v$($Latest.Version)</packageSourceUrl>"
            "<copyright>[^<]*</copyright>" = "<copyright>Copyright (c) 2017-$(Get-Date -Format yyyy) Nir Sofer</copyright>"
        }
        'tools\VERIFICATION.txt' = @{
            '%snapshotUrl%' = "$($Latest.ArchivedURL)"
            '%checksumType%' = "$($Latest.ChecksumType32.ToUpper())"
            '%checksumValue%' = "$($Latest.Checksum32)"
        }
    }
}

function global:au_GetLatest {
    $userAgent = 'Update checker of Chocolatey Community Package ''controlmymonitor'''
    $script:response = Invoke-WebRequest -Uri $projectUri -UserAgent $userAgent -UseBasicParsing

    $version = [Regex]::Matches($response.Content, '<td>ControlMyMonitor v(\d+(\.\d+){1,3})').Groups[1].Value

    return @{
        Url32 = 'https://www.nirsoft.net/utils/controlmymonitor.zip'
        Version = $version
    }
}

Update-Package -ChecksumFor None -NoReadme

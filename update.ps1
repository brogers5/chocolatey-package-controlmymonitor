Import-Module au

function global:au_BeforeUpdate ($Package)  {
    Set-DescriptionFromReadme -Package $Package -ReadmePath ".\DESCRIPTION.md"
}

function global:au_AfterUpdate ($Package)  {
    
}

function global:au_SearchReplace {
    @{
        "$($Latest.PackageName).nuspec" = @{
            "<packageSourceUrl>[^<]*</packageSourceUrl>" = "<packageSourceUrl>https://github.com/brogers5/chocolatey-package-$($Latest.PackageName)/tree/v$($Latest.Version)</packageSourceUrl>"
            "<copyright>[^<]*</copyright>" = "<copyright>Copyright (c) 2017-$(Get-Date -Format yyyy) Nir Sofer</copyright>"
        }
        'tools\chocolateyInstall.ps1' = @{
            "(^[$]checksum\s*=\s*)('.*')" = "`$1'$($Latest.Checksum32)'"
        }
    }
}

function global:au_GetLatest {
    # Query the latest version
    $uri = 'https://www.nirsoft.net/utils/control_my_monitor.html'
    $page = Invoke-WebRequest -Uri $uri -UserAgent "Update checker of Chocolatey Community Package 'controlmymonitor'"

    $version = [Version] [Regex]::Matches($page.Content, "<li>Version (.*):").Groups[1].Value

    return @{ Version = $version; }
}

Update-Package -NoReadme

# <img src="https://cdn.jsdelivr.net/gh/brogers5/chocolatey-package-controlmymonitor@f81521a0d30cdfb49cb36166993c94d6d9d50ef1/controlmymonitor.png" width="48" height="48"/> Chocolatey Package: [ControlMyMonitor](https://community.chocolatey.org/packages/controlmymonitor)

[![Chocolatey package version](https://img.shields.io/chocolatey/v/controlmymonitor.svg)](https://community.chocolatey.org/packages/controlmymonitor)
[![Chocolatey package download count](https://img.shields.io/chocolatey/dt/controlmymonitor.svg)](https://community.chocolatey.org/packages/controlmymonitor)

## Install

[Install Chocolatey](https://chocolatey.org/install), and run the following command to install the latest approved stable version from the Chocolatey Community Repository:

```shell
choco install controlmymonitor --source="'https://community.chocolatey.org/api/v2'"
```

Alternatively, the packages as published on the Chocolatey Community Repository will also be mirrored on this repository's [Releases page](https://github.com/brogers5/chocolatey-package-controlmymonitor/releases). The `nupkg` can be installed from the current directory as follows:

```shell
choco install controlmymonitor --source="'.'"
```

## Build

[Install Chocolatey](https://chocolatey.org/install), and the [Chocolatey Automatic Package Updater Module](https://github.com/majkinetor/au), then clone this repository.

Once cloned, simply run `build.ps1`. The ZIP archive is intentionally untracked to avoid bloating the repository, so the script will download the ControlMyMonitor portable ZIP archive from the mirror created by this package (to ensure reproducibility in case of an older version), then packs everything together.

A successful build will create `controlmymonitor.x.y.z.nupkg`, where `x.y.z` should be the Nuspec's normalized `version` value at build time.

>[!Note]
>As of Chocolatey v2.0.0, `version` values are normalized to contain a [SemVer 2.0.0](https://semver.org/spec/v2.0.0.html)-compliant patch number (i.e. only 2 segments will no longer be honored). Legacy package versions that did not contain these will be padded with a patch number of 0. Going forward, `version` will be padded accordingly for behavior consistency between v1 and v2 Chocolatey releases.

>[!Note]
>Chocolatey package builds are non-deterministic. Consequently, an independently built package's checksum will not match that of the officially published package.

## Update

This package should be automatically updated by the [Chocolatey Automatic Package Updater Module](https://github.com/majkinetor/au), with mirroring implemented by the [Selenium PowerShell module](https://github.com/adamdriscoll/selenium-powershell) driving save requests to [the Internet Archive's Wayback Machine](https://web.archive.org/) via [Mozilla Firefox](https://www.mozilla.org/firefox/new/). If it is outdated by more than a few days, please [open an issue](https://github.com/brogers5/chocolatey-package-controlmymonitor/issues).

AU expects the parent directory that contains this repository to share a name with the Nuspec (`controlmymonitor`). Your local repository should therefore be cloned accordingly:

```shell
git clone git@github.com:brogers5/chocolatey-package-controlmymonitor.git controlmymonitor
```

Alternatively, a junction point can be created that points to the local repository (preferably within a repository adopting the [AU packages template](https://github.com/majkinetor/au-packages-template)):

```shell
mklink /J controlmymonitor ..\chocolatey-package-controlmymonitor
```

Once created, simply run `update.ps1` from within the created directory/junction point. Assuming all goes well, the snapshot(s) will be created/used (if recently created) for the release, and all relevant files should change to reflect the latest version available. This will also build a new package version using the modified files.

Before submitting a pull request, please [test the package](https://docs.chocolatey.org/en-us/community-repository/moderation/package-verifier#steps-for-each-package) using the latest [Chocolatey Testing Environment](https://github.com/chocolatey-community/chocolatey-test-environment) first.

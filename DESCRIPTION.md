
---

### [choco://controlmymonitor](choco://controlmymonitor)
To use choco:// protocol URLs, install [(unofficial) choco:// Protocol support](https://community.chocolatey.org/packages/choco-protocol-support)

---

## ControlMyMonitor

ControlMyMonitor allows you view and modify the settings of your monitor (Also known as 'VCP Features'), like brightness, contrast, sharpness, red/green/blue color balance, OSD Language, Input Port (VGA, DVI, HDMI) and more...You can modify the monitor settings from the GUI and from command-line. You can also export all settings of your monitor into a configuration file and then later load the same configuration back into your monitor.

![ControlMyMonitor Screenshot](https://cdn.jsdelivr.net/gh/brogers5/chocolatey-package-controlmymonitor@00da38d808b41d340e82b0fc10f3be77e6f09309/Screenshot.png)

## Package Parameters

* `/NoShim` - Opt out of creating a GUI shim.
* `/Start` - Automatically start ControlMyMonitor after installation completes.

## Package Notes

For future upgrade operations, consider opting into Chocolatey's `useRememberedArgumentsForUpgrades` feature to avoid having to pass the same arguments with each upgrade:

```shell
choco feature enable --name="'useRememberedArgumentsForUpgrades'"
```

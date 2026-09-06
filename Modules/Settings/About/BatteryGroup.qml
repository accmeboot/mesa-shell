import Quickshell.Services.UPower

import qs.Services
import qs.Modules.Settings.Common

PanelSection {
  id: root

  readonly property UPowerDevice device: UPower.displayDevice
  readonly property bool available: root.device?.isLaptopBattery && root.device.isPresent
  readonly property int percentage: root.device ? Math.round(root.device.percentage * 100) : 0
  readonly property bool charging: root.device?.state === UPowerDeviceState.Charging || root.device?.state === UPowerDeviceState.PendingCharge
  readonly property real remaining: root.charging ? root.device.timeToFull : root.device?.timeToEmpty ?? 0

  function formatDuration(seconds: real): string {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.round(seconds % 3600 / 60);

    return hours > 0 ? `${hours}h ${minutes}m` : `${minutes}m`;
  }

  title: "Battery"
  visible: root.available

  PanelRow {
    label: root.device?.model || "Battery"
    value: {
      switch (root.device?.state) {
      case UPowerDeviceState.Charging: return "Charging";
      case UPowerDeviceState.PendingCharge: return "Plugged in";
      case UPowerDeviceState.PendingDischarge:
      case UPowerDeviceState.Discharging:
        return "On battery";
      case UPowerDeviceState.FullyCharged: return "Fully charged";
      case UPowerDeviceState.Empty: return "Empty";
      default: return "Unknown";
      }
    }
    valueColor: {
      const colors = ConfigService.colors;

      switch (root.device?.state) {
      case UPowerDeviceState.Charging:
      case UPowerDeviceState.FullyCharged:
        return colors.ok;
      case UPowerDeviceState.PendingCharge:
      case UPowerDeviceState.PendingDischarge:
        return colors.attention;
      case UPowerDeviceState.Empty: return colors.critical;
      case UPowerDeviceState.Discharging: return colors.foreground;
      default: return colors.on_surface;
      }
    }
  }

  PanelRow {
    label: "Charge"
    value: `${root.percentage}%`
    valueColor: ColorService.threshold(root.percentage, 50, 20)
  }

  PanelRow {
    visible: root.device?.healthSupported ?? false
    label: "Health"
    value: `${Math.round(root.device?.healthPercentage ?? 0)}%`
    valueColor: ConfigService.colors.foreground
  }

  PanelRow {
    visible: root.remaining > 0
    label: root.charging ? "Until full" : "Remaining"
    value: root.formatDuration(root.remaining)
    valueColor: ConfigService.colors.foreground
  }

  PanelRow {
    visible: (root.device?.changeRate ?? 0) > 0
    label: "Power draw"
    value: `${root.device.changeRate.toFixed(1)} W`
    valueColor: ConfigService.colors.foreground
  }
}

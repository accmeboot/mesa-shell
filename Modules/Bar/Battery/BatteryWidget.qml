import Quickshell.Services.UPower

import qs.Services
import qs.Components

MesaPanelWidget {
  id: root

  readonly property UPowerDevice device: UPower.displayDevice
  readonly property int percentage: root.device ? Math.round(root.device.percentage * 100) : 0

  readonly property string level: {
    if (root.percentage >= 88) return "100";
    if (root.percentage >= 63) return "070";
    if (root.percentage >= 38) return "040";
    if (root.percentage >= 13) return "020";
    if (root.percentage >= 5) return "010";
    return "000";
  }

  readonly property bool onAcAdapter: {
    switch (root.device?.state) {
    case UPowerDeviceState.PendingCharge:
    case UPowerDeviceState.FullyCharged:
      return true;
    default: return false;
    }
  }

  visible: root.device?.isLaptopBattery ?? false

  panel: "battery"
  icon: {
    if (!root.device) return "battery-missing";

    switch (root.device.state) {
    case UPowerDeviceState.Charging: return `battery-${root.level}-charging`;
    case UPowerDeviceState.PendingCharge:
    case UPowerDeviceState.FullyCharged:
      return "battery-ac-adapter";
    case UPowerDeviceState.Empty: return "battery-000";
    default: return `battery-${root.level}`;
    }
  }
  iconColor: {
    const colors = ThemeService.colors;

    if (root.onAcAdapter) return colors.ok;
    if (root.percentage < 20) return colors.critical;
    if (root.percentage < 50) return colors.attention;

    return colors.foreground;
  }

  content: BatteryPanel {}
}

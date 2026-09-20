import Quickshell.Services.UPower

import qs.Services
import qs.Components

MesaPanelWidget {
  id: root

  readonly property UPowerDevice device: UPower.displayDevice
  readonly property int percentage: root.device ? Math.round(root.device.percentage * 100) : 0

  readonly property string level: String(Math.floor(root.percentage / 10) * 10).padStart(3, "0")

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
  iconColor: ColorService.threshold(root.percentage, 50, 20)

  content: BatteryPanel {}
}

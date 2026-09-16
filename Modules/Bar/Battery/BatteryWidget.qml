import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

RowLayout {
  id: root

  required property var screen

  property bool isOpen: false

  readonly property UPowerDevice device: UPower.displayDevice
  readonly property int percentage: root.device ? Math.round(root.device.percentage * 100) : 0

  readonly property string level: String(Math.floor(root.percentage / 10) * 10).padStart(3, "0")

  readonly property string icon: {
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

  visible: root.device?.isLaptopBattery ?? false

  spacing: 0

  MesaButton {
    id: button

    Layout.fillHeight: true

    icon: root.icon
    contentColor: ColorService.threshold(root.percentage, 50, 20)

    onClicked: root.isOpen = !root.isOpen
  }

  MesaPopup {
    open: root.isOpen
    screen: root.screen
    exclude: root
    namespace: "mesa-battery"

    content: BatteryPanel {}

    onDismissed: root.isOpen = false
  }
}

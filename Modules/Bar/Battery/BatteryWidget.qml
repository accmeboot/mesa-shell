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

  readonly property string icon: {
    switch (root.device?.state) {
    case UPowerDeviceState.Charging: return "battery-full-charging";
    case UPowerDeviceState.PendingCharge: return "battery_plugged";
    case UPowerDeviceState.FullyCharged: return "battery-full";
    case UPowerDeviceState.Empty: return "battery-empty";
    }

    if (root.percentage >= 90) return "battery-full";
    if (root.percentage >= 65) return "battery-good";
    if (root.percentage >= 40) return "battery-medium";
    if (root.percentage >= 15) return "battery-low";

    return "battery-empty";
  }

  visible: root.device?.isLaptopBattery ?? false

  spacing: 0

  MesaButton {
    id: button

    Layout.fillHeight: true

    icon: root.icon
    contentColor: ColorService.threshold(root.percentage, 50, 20)

    onClicked: root.isOpen = !root.isOpen
    horizontalPadding: ConfigService.spacing * 2
  }

  MesaPopup {
    open: root.isOpen
    screen: root.screen
    exclude: root
    namespace: "mesa-battery"
    anchorRight: root.x + button.x + button.width

    content: BatteryPanel {}

    onDismissed: root.isOpen = false
  }
}

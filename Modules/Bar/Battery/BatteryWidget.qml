import Quickshell.Services.UPower
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

RowLayout {
  id: root

  required property var screen
  required property int popupWidth

  readonly property bool isOpen: root.visible && PanelService.current === "battery" && PanelService.screen === root.screen.name

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

    onClicked: PanelService.toggle("battery", root.screen.name)
  }

  MesaPopup {
    open: root.isOpen
    screen: root.screen
    width: root.popupWidth
    exclude: root
    namespace: "mesa-battery"
    keyboardFocus: WlrKeyboardFocus.Exclusive

    content: BatteryPanel {}

    onDismissed: PanelService.close("battery")
  }
}

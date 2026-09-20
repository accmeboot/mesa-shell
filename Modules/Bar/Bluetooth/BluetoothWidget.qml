import Quickshell.Bluetooth
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

RowLayout {
  id: root

  required property var screen
  required property int popupWidth

  readonly property bool isOpen: root.visible && PanelService.current === "bluetooth" && PanelService.screen === root.screen.name

  readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
  readonly property var connectedDevices: Bluetooth.devices.values.filter(device => device.connected)

  readonly property string icon: {
    switch (root.adapter?.state) {
    case BluetoothAdapterState.Enabled: return root.connectedDevices.length > 0 ? "bluetooth-paired" : "bluetooth-active";
    case BluetoothAdapterState.Enabling:
    case BluetoothAdapterState.Disabling:
      return "bluetooth-active";
    default: return "bluetooth-disabled";
    }
  }

  readonly property color iconColor: {
    const colors = ThemeService.colors;

    switch (root.adapter?.state) {
    case BluetoothAdapterState.Enabled: return root.connectedDevices.length > 0 ? colors.ok : colors.foreground;
    case BluetoothAdapterState.Enabling:
    case BluetoothAdapterState.Disabling:
      return colors.attention;
    case BluetoothAdapterState.Blocked: return colors.critical;
    default: return colors.on_surface;
    }
  }

  visible: root.adapter !== null

  spacing: 0

  MesaButton {
    id: button

    Layout.fillHeight: true

    icon: root.icon
    contentColor: root.iconColor

    onClicked: PanelService.toggle("bluetooth", root.screen.name)
  }

  MesaPopup {
    open: root.isOpen
    screen: root.screen
    width: root.popupWidth
    exclude: root
    namespace: "mesa-bluetooth"
    keyboardFocus: WlrKeyboardFocus.Exclusive

    content: BluetoothPanel {}

    onDismissed: PanelService.close("bluetooth")
  }
}

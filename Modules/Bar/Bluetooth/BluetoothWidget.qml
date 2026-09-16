import Quickshell.Bluetooth
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

RowLayout {
  id: root

  required property var screen

  property bool isOpen: false

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

    onClicked: root.isOpen = !root.isOpen
    horizontalPadding: ConfigService.spacing * 2
  }

  MesaPopup {
    open: root.isOpen
    screen: root.screen
    exclude: root
    namespace: "mesa-bluetooth"
    anchorRight: root.x + button.x + button.width
    keyboardFocus: WlrKeyboardFocus.OnDemand

    content: BluetoothPanel {}

    onDismissed: root.isOpen = false
  }
}

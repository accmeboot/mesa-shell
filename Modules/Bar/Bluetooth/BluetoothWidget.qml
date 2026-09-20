import Quickshell.Bluetooth

import qs.Services
import qs.Components

MesaPanelWidget {
  id: root

  readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
  readonly property var connectedDevices: Bluetooth.devices.values.filter(device => device.connected)

  visible: root.adapter !== null

  panel: "bluetooth"
  icon: {
    switch (root.adapter?.state) {
    case BluetoothAdapterState.Enabled: return root.connectedDevices.length > 0 ? "bluetooth-paired" : "bluetooth-active";
    case BluetoothAdapterState.Enabling:
    case BluetoothAdapterState.Disabling:
      return "bluetooth-active";
    default: return "bluetooth-disabled";
    }
  }
  iconColor: {
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

  content: BluetoothPanel {}
}

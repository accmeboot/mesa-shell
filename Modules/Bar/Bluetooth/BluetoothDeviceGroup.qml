import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth

import qs.Services
import qs.Components

MesaSection {
  id: root

  readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
  readonly property var devices: Bluetooth.devices.values
  readonly property var paired: root.devices.filter(device => device.paired).sort((a, b) => {
    if (a.connected !== b.connected) return a.connected ? -1 : 1;

    return a.name.localeCompare(b.name);
  })
  readonly property var available: root.devices.filter(device => !device.paired && device.deviceName !== "")
  readonly property var listed: root.scanning ? root.paired.concat(root.available) : root.paired
  readonly property bool scanning: root.adapter !== null && root.adapter.discovering

  property BluetoothDevice pairingDevice: null

  title: "Devices"

  Component.onDestruction: if (root.adapter) root.adapter.discovering = false

  Binding {
    target: root.adapter
    property: "discovering"
    value: true
    when: root.adapter?.state === BluetoothAdapterState.Enabled
    restoreMode: Binding.RestoreNone
  }

  BluetoothAgent {
    id: pairingAgent
  }

  Connections {
    target: root.pairingDevice

    function onPairedChanged(): void {
      const device = root.pairingDevice;

      if (!device || !device.paired) return;

      device.trusted = true;
      root.pairingDevice = null;
    }
  }

  MesaRow {
    visible: root.listed.length === 0
    label: root.scanning ? "Scanning" : "No devices"
    labelColor: root.scanning ? ThemeService.colors.attention : ThemeService.colors.on_surface
  }

  ScriptModel {
    id: listedModel

    values: root.listed
  }

  Repeater {
    model: listedModel

    MesaRow {
      id: deviceRow

      required property BluetoothDevice modelData

      readonly property BluetoothDevice device: deviceRow.modelData

      label: deviceRow.device.name
      value: {
        if (deviceRow.device.pairing) return "Pairing";
        if (!deviceRow.device.paired) return "Not paired";

        switch (deviceRow.device.state) {
        case BluetoothDeviceState.Connected: return "Connected";
        case BluetoothDeviceState.Connecting: return "Connecting";
        case BluetoothDeviceState.Disconnecting: return "Disconnecting";
        default: return "Disconnected";
        }
      }
      valueColor: {
        const colors = ThemeService.colors;

        if (deviceRow.device.pairing) return colors.attention;
        if (!deviceRow.device.paired) return colors.on_surface;

        switch (deviceRow.device.state) {
        case BluetoothDeviceState.Connected: return colors.ok;
        case BluetoothDeviceState.Connecting:
        case BluetoothDeviceState.Disconnecting:
          return colors.attention;
        default: return colors.on_surface;
        }
      }
      interactive: true
      menu: deviceMenu

      MesaText {
        Layout.alignment: Qt.AlignVCenter

        visible: deviceRow.device.connected && deviceRow.device.batteryAvailable
        text: `${Math.round(deviceRow.device.battery * 100)}%`
        color: deviceRow.tone(ColorService.threshold(deviceRow.device.battery * 100, 30, 15))
      }

      MesaChevron {}

      MesaRowMenu {
        id: deviceMenu

        MesaMenuEntry {
          text: `Address   ${deviceRow.device.address}`
          enabled: false
        }

        MesaMenuEntry {
          isSeparator: true
        }

        MesaMenuEntry {
          visible: deviceRow.device.paired
          text: "Connect automatically"
          checkable: true
          checked: deviceRow.device.trusted

          onTriggered: deviceRow.device.trusted = !deviceRow.device.trusted
        }

        MesaMenuEntry {
          visible: deviceRow.device.paired
          text: "Wake from sleep"
          checkable: true
          checked: deviceRow.device.wakeAllowed

          onTriggered: deviceRow.device.wakeAllowed = !deviceRow.device.wakeAllowed
        }

        MesaMenuEntry {
          visible: deviceRow.device.paired
          isSeparator: true
        }

        MesaMenuEntry {
          visible: deviceRow.device.paired
          enabled: deviceRow.device.state === BluetoothDeviceState.Connected || deviceRow.device.state === BluetoothDeviceState.Disconnected
          text: deviceRow.device.connected ? "Disconnect" : "Connect"

          onTriggered: {
            if (deviceRow.device.connected) deviceRow.device.disconnect();
            else deviceRow.device.connect();
          }
        }

        MesaMenuEntry {
          visible: deviceRow.device.paired
          text: "Forget"

          onTriggered: deviceRow.device.forget()
        }

        MesaMenuEntry {
          visible: !deviceRow.device.paired
          enabled: pairingAgent.registered
          text: deviceRow.device.pairing ? "Cancel pairing" : "Pair"

          onTriggered: {
            if (deviceRow.device.pairing) {
              deviceRow.device.cancelPair();
              root.pairingDevice = null;
              return;
            }

            root.pairingDevice = deviceRow.device;
            deviceRow.device.pair();
          }
        }
      }
    }
  }
}

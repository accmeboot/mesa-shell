import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth

import qs.Services
import qs.Components
import qs.Modules.Settings.Common

PanelSection {
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

  property BluetoothDevice selectedDevice: null
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

  PanelRow {
    visible: root.listed.length === 0
    indented: true
    label: root.scanning ? "Scanning" : "No devices"
    labelColor: root.scanning ? ConfigService.colors.attention : ConfigService.colors.on_surface
  }

  Repeater {
    model: root.listed

    ColumnLayout {
      id: entry

      required property BluetoothDevice modelData

      readonly property bool selected: root.selectedDevice === entry.modelData

      Layout.fillWidth: true

      spacing: 0

      PanelRow {
        label: entry.modelData.name
        value: {
          if (entry.modelData.pairing) return "Pairing";
          if (!entry.modelData.paired) return "Not paired";

          switch (entry.modelData.state) {
          case BluetoothDeviceState.Connected: return "Connected";
          case BluetoothDeviceState.Connecting: return "Connecting";
          case BluetoothDeviceState.Disconnecting: return "Disconnecting";
          default: return "Disconnected";
          }
        }
        valueColor: {
          const colors = ConfigService.colors;

          if (entry.modelData.pairing) return colors.attention;
          if (!entry.modelData.paired) return colors.on_surface;

          switch (entry.modelData.state) {
          case BluetoothDeviceState.Connected: return colors.ok;
          case BluetoothDeviceState.Connecting:
          case BluetoothDeviceState.Disconnecting:
            return colors.attention;
          default: return colors.on_surface;
          }
        }
        interactive: true
        selected: entry.selected

        leading: Item {
          implicitWidth: dot.implicitWidth
          implicitHeight: dot.implicitHeight

          MesaIcon {
            id: dot

            visible: entry.modelData.connected
            name: "dot"
            size: Math.round(ConfigService.font.size * 0.5)
            color: ConfigService.colors.ok
          }
        }

        onClicked: root.selectedDevice = entry.selected ? null : entry.modelData

        MesaText {
          Layout.alignment: Qt.AlignVCenter

          visible: entry.modelData.connected && entry.modelData.batteryAvailable
          text: `${Math.round(entry.modelData.battery * 100)}%`
          color: ColorService.threshold(entry.modelData.battery * 100, 30, 15)
        }
      }

      PanelRow {
        visible: entry.selected
        selected: true
        indented: true
        label: "Address"
        value: entry.modelData.address
      }

      PanelRow {
        visible: entry.selected && entry.modelData.paired
        selected: true
        indented: true
        label: "Connect automatically"

        MesaIndicator {
          Layout.alignment: Qt.AlignVCenter

          checked: entry.modelData.trusted

          onToggled: entry.modelData.trusted = !entry.modelData.trusted
        }
      }

      PanelRow {
        visible: entry.selected && entry.modelData.paired
        selected: true
        indented: true
        label: "Wake from sleep"

        MesaIndicator {
          Layout.alignment: Qt.AlignVCenter

          checked: entry.modelData.wakeAllowed

          onToggled: entry.modelData.wakeAllowed = !entry.modelData.wakeAllowed
        }
      }

      PanelRow {
        visible: entry.selected
        selected: true
        indented: true

        MesaButton {
          Layout.alignment: Qt.AlignVCenter

          visible: entry.modelData.paired
          enabled: entry.modelData.state === BluetoothDeviceState.Connected || entry.modelData.state === BluetoothDeviceState.Disconnected
          text: entry.modelData.connected ? "Disconnect" : "Connect"

          onClicked: {
            if (entry.modelData.connected) entry.modelData.disconnect();
            else entry.modelData.connect();
          }
        }

        MesaButton {
          Layout.alignment: Qt.AlignVCenter

          visible: entry.modelData.paired
          text: "Forget"

          onClicked: {
            if (entry.selected) root.selectedDevice = null;
            entry.modelData.forget();
          }
        }

        MesaButton {
          Layout.alignment: Qt.AlignVCenter

          visible: !entry.modelData.paired
          enabled: pairingAgent.registered
          text: entry.modelData.pairing ? "Cancel" : "Pair"
          contentColor: entry.modelData.pairing ? ConfigService.colors.attention : ConfigService.colors.foreground

          onClicked: {
            if (entry.modelData.pairing) {
              entry.modelData.cancelPair();
              root.pairingDevice = null;
              return;
            }

            root.pairingDevice = entry.modelData;
            entry.modelData.pair();
          }
        }
      }
    }
  }
}

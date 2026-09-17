import QtQuick
import QtQuick.Layouts
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

  MesaRow {
    visible: root.listed.length === 0
    label: root.scanning ? "Scanning" : "No devices"
    labelColor: root.scanning ? ThemeService.colors.attention : ThemeService.colors.on_surface
  }

  Repeater {
    model: root.listed

    ColumnLayout {
      id: entry

      required property BluetoothDevice modelData

      readonly property bool selected: root.selectedDevice === entry.modelData

      Layout.fillWidth: true
      Layout.topMargin: entry.selected ? ConfigService.gapSmall : 0
      Layout.bottomMargin: entry.selected ? ConfigService.gapSmall : 0

      spacing: 0

      MesaRow {
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
          const colors = ThemeService.colors;

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

        onClicked: root.selectedDevice = entry.selected ? null : entry.modelData

        MesaText {
          Layout.alignment: Qt.AlignVCenter

          visible: entry.modelData.connected && entry.modelData.batteryAvailable
          text: `${Math.round(entry.modelData.battery * 100)}%`
          color: ColorService.threshold(entry.modelData.battery * 100, 30, 15)
        }

        MesaIcon {
          Layout.alignment: Qt.AlignVCenter

          name: "pan-end"
          size: ConfigService.iconSizeSmall
          color: ThemeService.colors.foreground
          rotation: entry.selected ? -90 : 90
        }
      }

      MesaRow {
        visible: entry.selected
        selected: true
        label: "Address"
        value: entry.modelData.address
      }

      MesaRow {
        visible: entry.selected && entry.modelData.paired
        selected: true
        label: "Connect automatically"

        MesaIndicator {
          Layout.alignment: Qt.AlignVCenter

          checked: entry.modelData.trusted

          onToggled: entry.modelData.trusted = !entry.modelData.trusted
        }
      }

      MesaRow {
        visible: entry.selected && entry.modelData.paired
        selected: true
        label: "Wake from sleep"

        MesaIndicator {
          Layout.alignment: Qt.AlignVCenter

          checked: entry.modelData.wakeAllowed

          onToggled: entry.modelData.wakeAllowed = !entry.modelData.wakeAllowed
        }
      }

      MesaRow {
        visible: entry.selected
        selected: true

        MesaButton {
          Layout.alignment: Qt.AlignVCenter

          visible: entry.modelData.paired
          enabled: entry.modelData.state === BluetoothDeviceState.Connected || entry.modelData.state === BluetoothDeviceState.Disconnected
          text: entry.modelData.connected ? "Disconnect" : "Connect"
          color: !enabled ? ThemeService.colors.attention : entry.modelData.connected ? ThemeService.colors.critical : ThemeService.colors.highlight
          contentColor: ThemeService.colors.background
          disabledContentColor: ThemeService.colors.background

          onClicked: {
            if (entry.modelData.connected) entry.modelData.disconnect();
            else entry.modelData.connect();
          }
        }

        MesaButton {
          Layout.alignment: Qt.AlignVCenter

          visible: entry.modelData.paired
          text: "Forget"
          color: ThemeService.colors.critical
          contentColor: ThemeService.colors.background

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
          color: !enabled ? ThemeService.colors.surface : entry.modelData.pairing ? ThemeService.colors.critical : ThemeService.colors.highlight
          contentColor: ThemeService.colors.background

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

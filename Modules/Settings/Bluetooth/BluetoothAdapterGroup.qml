import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth

import qs.Services
import qs.Components
import qs.Modules.Settings.Common

PanelSection {
  id: root

  readonly property var adapters: Bluetooth.adapters.values
  readonly property alias count: repeater.count

  function formatTimeout(seconds: int): string {
    if (seconds === 0) return "never";
    if (seconds % 60 === 0) return `${seconds / 60} min`;

    return `${seconds}s`;
  }

  title: "Adapter"
  visible: root.count > 0

  Repeater {
    id: repeater

    model: root.adapters

    ColumnLayout {
      id: entry

      required property BluetoothAdapter modelData

      readonly property bool busy: entry.modelData.state === BluetoothAdapterState.Enabling || entry.modelData.state === BluetoothAdapterState.Disabling
      readonly property bool blocked: entry.modelData.state === BluetoothAdapterState.Blocked

      Layout.fillWidth: true

      spacing: 0

      PanelRow {
        label: entry.modelData.name || entry.modelData.adapterId
        sublabel: entry.modelData.adapterId
        value: {
          switch (entry.modelData.state) {
          case BluetoothAdapterState.Enabled: return "Enabled";
          case BluetoothAdapterState.Disabled: return "Disabled";
          case BluetoothAdapterState.Enabling: return "Enabling";
          case BluetoothAdapterState.Disabling: return "Disabling";
          case BluetoothAdapterState.Blocked: return "Blocked by rfkill";
          default: return "Unknown";
          }
        }
        valueColor: {
          const colors = ConfigService.colors;

          switch (entry.modelData.state) {
          case BluetoothAdapterState.Enabled: return colors.ok;
          case BluetoothAdapterState.Enabling:
          case BluetoothAdapterState.Disabling:
            return colors.attention;
          case BluetoothAdapterState.Blocked: return colors.critical;
          default: return colors.on_surface;
          }
        }

        MesaIndicator {
          Layout.alignment: Qt.AlignVCenter

          enabled: !entry.busy && !entry.blocked
          checked: entry.modelData.enabled

          onToggled: entry.modelData.enabled = !entry.modelData.enabled
        }
      }

      PanelRow {
        label: "Discoverable"
        value: entry.modelData.discoverable && entry.modelData.discoverableTimeout > 0 ? `resets after ${root.formatTimeout(entry.modelData.discoverableTimeout)}` : ""

        MesaIndicator {
          Layout.alignment: Qt.AlignVCenter

          enabled: entry.modelData.enabled
          checked: entry.modelData.discoverable

          onToggled: entry.modelData.discoverable = !entry.modelData.discoverable
        }
      }
    }
  }
}

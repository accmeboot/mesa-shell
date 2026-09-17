import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth

import qs.Services
import qs.Components

MesaSection {
  id: root

  readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
  readonly property bool busy: root.adapter?.state === BluetoothAdapterState.Enabling || root.adapter?.state === BluetoothAdapterState.Disabling
  readonly property bool blocked: root.adapter?.state === BluetoothAdapterState.Blocked

  function formatTimeout(seconds: int): string {
    if (seconds === 0) return "never";
    if (seconds % 60 === 0) return `${seconds / 60} min`;

    return `${seconds}s`;
  }

  title: "Adapter"
  visible: root.adapter !== null

  actions: [
    MesaText {
      Layout.alignment: Qt.AlignVCenter

      visible: root.blocked
      text: "Blocked by rfkill"
      color: ThemeService.colors.critical
    },
    MesaIndicator {
      Layout.alignment: Qt.AlignVCenter

      enabled: !root.busy && !root.blocked
      checked: root.adapter?.enabled ?? false

      onToggled: root.adapter.enabled = !root.adapter.enabled
    }
  ]

  MesaRow {
    label: "Name"
    value: root.adapter?.name || root.adapter?.adapterId || "Unknown"
    valueColor: ThemeService.colors.foreground
  }

  MesaRow {
    label: "Discoverable"
    value: root.adapter?.discoverable && root.adapter.discoverableTimeout > 0 ? `resets after ${root.formatTimeout(root.adapter.discoverableTimeout)}` : ""

    MesaIndicator {
      Layout.alignment: Qt.AlignVCenter

      enabled: root.adapter?.enabled ?? false
      checked: root.adapter?.discoverable ?? false

      onToggled: root.adapter.discoverable = !root.adapter.discoverable
    }
  }
}

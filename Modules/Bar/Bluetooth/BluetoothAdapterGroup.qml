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

  MesaRow {
    label: "Enabled"
    value: root.blocked ? "Blocked by rfkill" : ""
    valueColor: ThemeService.colors.critical
    interactive: !root.busy && !root.blocked

    onClicked: root.adapter.enabled = !root.adapter.enabled

    MesaIndicator {
      Layout.alignment: Qt.AlignVCenter

      activeFocusOnTab: false
      enabled: !root.busy && !root.blocked
      checked: root.adapter?.enabled ?? false

      onToggled: root.adapter.enabled = !root.adapter.enabled
    }
  }

  MesaRow {
    label: "Discoverable"
    value: root.adapter?.discoverable && root.adapter.discoverableTimeout > 0 ? `resets after ${root.formatTimeout(root.adapter.discoverableTimeout)}` : ""
    valueColor: ThemeService.colors.on_surface
    interactive: root.adapter?.enabled ?? false

    onClicked: root.adapter.discoverable = !root.adapter.discoverable

    MesaIndicator {
      Layout.alignment: Qt.AlignVCenter

      activeFocusOnTab: false
      enabled: root.adapter?.enabled ?? false
      checked: root.adapter?.discoverable ?? false

      onToggled: root.adapter.discoverable = !root.adapter.discoverable
    }
  }

  MesaRow {
    label: "Name"
    value: root.adapter?.name || root.adapter?.adapterId || ""
    fallback: "Unknown"
  }
}

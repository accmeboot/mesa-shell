import QtQuick
import QtQuick.Layouts
import Quickshell.Networking

import qs.Services
import qs.Components
import qs.Modules.Settings.Common

PanelSection {
  id: root

  readonly property var devices: Networking.devices.values.filter(device => device.type === DeviceType.Wired)
  readonly property alias count: repeater.count

  property WiredDevice selectedDevice: null

  title: "Ethernet"
  visible: root.count > 0

  Repeater {
    id: repeater

    model: root.devices

    ColumnLayout {
      id: entry

      required property WiredDevice modelData

      readonly property bool selected: root.selectedDevice === entry.modelData

      Layout.fillWidth: true

      spacing: 0

      PanelRow {
        label: entry.modelData.name
        value: {
          if (!entry.modelData.hasLink) return "No cable";

          switch (entry.modelData.state) {
          case ConnectionState.Connected: return "Connected";
          case ConnectionState.Connecting: return "Connecting";
          case ConnectionState.Disconnecting: return "Disconnecting";
          case ConnectionState.Disconnected: return "Disconnected";
          default: return "Unknown";
          }
        }
        valueColor: {
          const colors = ConfigService.colors;

          if (!entry.modelData.hasLink) return colors.on_surface;

          switch (entry.modelData.state) {
          case ConnectionState.Connecting:
          case ConnectionState.Disconnecting:
            return colors.attention;
          default:
            return ColorService.status(entry.modelData.connected);
          }
        }
        interactive: true
        selected: entry.selected

        onClicked: root.selectedDevice = entry.selected ? null : entry.modelData
      }

      PanelRow {
        visible: entry.selected
        selected: true
        label: "MAC"
        value: entry.modelData.address || "Unknown"
      }

      PanelRow {
        visible: entry.selected && entry.modelData.hasLink && entry.modelData.linkSpeed > 0
        selected: true
        label: "Link"
        value: `${entry.modelData.linkSpeed} Mbps`
      }

      PanelRow {
        visible: entry.selected
        selected: true
        label: "Autoconnect"

        MesaIndicator {
          Layout.alignment: Qt.AlignVCenter

          checked: entry.modelData.autoconnect

          onToggled: entry.modelData.autoconnect = !entry.modelData.autoconnect
        }
      }

      PanelRow {
        id: actions

        readonly property Network network: entry.modelData.network

        visible: entry.selected && (entry.modelData.connected || actions.network !== null)
        selected: true

        MesaButton {
          Layout.alignment: Qt.AlignVCenter

          enabled: !(actions.network && actions.network.stateChanging)
          text: entry.modelData.connected ? "Disconnect" : "Connect"

          onClicked: {
            if (entry.modelData.connected) entry.modelData.disconnect();
            else actions.network.connect();
          }
        }
      }
    }
  }
}

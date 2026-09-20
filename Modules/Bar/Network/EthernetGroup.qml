import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking

import qs.Services
import qs.Components

MesaSection {
  id: root

  readonly property var devices: Networking.devices.values.filter(device => device.type === DeviceType.Wired)
  readonly property alias count: repeater.count

  property WiredDevice selectedDevice: null

  title: "Ethernet"
  visible: root.count > 0

  ScriptModel {
    id: devicesModel

    values: root.devices
  }

  Repeater {
    id: repeater

    model: devicesModel

    MesaExpander {
      id: entry

      required property WiredDevice modelData

      expanded: root.selectedDevice === entry.modelData

      MesaRow {
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
          const colors = ThemeService.colors;

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
        selected: entry.expanded

        onClicked: root.selectedDevice = entry.expanded ? null : entry.modelData

        MesaChevron {
          expanded: entry.expanded
        }
      }

      MesaRow {
        visible: entry.expanded
        selected: true
        label: "MAC"
        value: entry.modelData.address
        fallback: "Unknown"
        valueColor: ThemeService.colors.on_surface
      }

      MesaRow {
        visible: entry.expanded && entry.modelData.hasLink && entry.modelData.linkSpeed > 0
        selected: true
        label: "Link"
        value: `${entry.modelData.linkSpeed} Mbps`
        valueColor: ThemeService.colors.on_surface
      }

      MesaRow {
        visible: entry.expanded
        selected: true
        label: "Autoconnect"

        MesaIndicator {
          Layout.alignment: Qt.AlignVCenter

          checked: entry.modelData.autoconnect

          onToggled: entry.modelData.autoconnect = !entry.modelData.autoconnect
        }
      }

      MesaRow {
        id: actions

        readonly property Network network: entry.modelData.network

        visible: entry.expanded && (entry.modelData.connected || actions.network !== null)
        selected: true

        MesaButton {
          Layout.alignment: Qt.AlignVCenter

          enabled: !(actions.network && actions.network.stateChanging)
          text: entry.modelData.connected ? "Disconnect" : "Connect"
          accent: entry.modelData.connected ? ThemeService.colors.critical : ThemeService.colors.highlight

          onClicked: {
            if (entry.modelData.connected) entry.modelData.disconnect();
            else actions.network.connect();
          }
        }
      }
    }
  }
}

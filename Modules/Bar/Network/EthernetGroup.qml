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

  title: "Ethernet"
  visible: root.count > 0

  ScriptModel {
    id: devicesModel

    values: root.devices
  }

  Repeater {
    id: repeater

    model: devicesModel

    MesaRow {
      id: deviceRow

      required property WiredDevice modelData

      readonly property WiredDevice device: deviceRow.modelData
      readonly property Network network: deviceRow.device.network

      label: deviceRow.device.name
      value: {
        if (!deviceRow.device.hasLink) return "No cable";

        switch (deviceRow.device.state) {
        case ConnectionState.Connected: return "Connected";
        case ConnectionState.Connecting: return "Connecting";
        case ConnectionState.Disconnecting: return "Disconnecting";
        case ConnectionState.Disconnected: return "Disconnected";
        default: return "Unknown";
        }
      }
      valueColor: {
        const colors = ThemeService.colors;

        if (!deviceRow.device.hasLink) return colors.on_surface;

        switch (deviceRow.device.state) {
        case ConnectionState.Connecting:
        case ConnectionState.Disconnecting:
          return colors.attention;
        default:
          return ColorService.status(deviceRow.device.connected);
        }
      }
      interactive: true
      menu: deviceMenu

      MesaText {
        Layout.alignment: Qt.AlignVCenter

        visible: deviceRow.device.hasLink && deviceRow.device.linkSpeed > 0
        text: `${deviceRow.device.linkSpeed} Mbps`
        color: deviceRow.mutedColor
      }

      MesaChevron {}

      MesaRowMenu {
        id: deviceMenu

        MesaMenuEntry {
          text: `MAC   ${deviceRow.device.address || "Unknown"}`
          enabled: false
        }

        MesaMenuEntry {
          isSeparator: true
        }

        MesaMenuEntry {
          text: "Autoconnect"
          checkable: true
          checked: deviceRow.device.autoconnect

          onTriggered: deviceRow.device.autoconnect = !deviceRow.device.autoconnect
        }

        MesaMenuEntry {
          visible: deviceRow.device.connected || deviceRow.network !== null
          isSeparator: true
        }

        MesaMenuEntry {
          visible: deviceRow.device.connected || deviceRow.network !== null
          enabled: !(deviceRow.network && deviceRow.network.stateChanging)
          text: deviceRow.device.connected ? "Disconnect" : "Connect"

          onTriggered: {
            if (deviceRow.device.connected) deviceRow.device.disconnect();
            else deviceRow.network.connect();
          }
        }
      }
    }
  }
}

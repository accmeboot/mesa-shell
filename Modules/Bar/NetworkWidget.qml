import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking

import qs.Components
import qs.Services

Rectangle {
  id: root

  color: ThemeService.colors.background

  implicitWidth: networkRow.implicitWidth + ConfigService.spacing
  implicitHeight: networkRow.implicitHeight + ConfigService.spacing

  property var device: Networking.devices.values.find((d) => d.connected)

  readonly property string ssid: {
    if (!device || device.type !== DeviceType.Wifi) return ""

    const connectedWifi = device.networks.values
      .find((n) => n.state === ConnectionState.Connected)

    return connectedWifi ? connectedWifi.name : ""
  }

  readonly property bool connected: {
    if (!device) return false

    if (device.type === DeviceType.Wifi) return ssid !== ""

    return true
  }

  readonly property string icon: {
    if (!device) return "network-wireless-offline"

    if (device.type === DeviceType.Wifi) return connected ? "network-wireless-signal-excellent" : "network-wireless-offline"

    return "network-wired"
  }

  RowLayout {
    id: networkRow
    anchors.centerIn: parent

    MesaIcon {
      name: root.icon
      Layout.alignment: Qt.AlignTop
      Layout.topMargin: Math.round(label.baselineOffset + glyphs.tightBoundingRect.y + glyphs.tightBoundingRect.height / 2 - size / 2)
      size: {
        const base = Math.round(ConfigService.font.size * 1.5)
        return base + Math.abs(glyphs.tightBoundingRect.height - base) % 2
      }
      color: ColorService.status(root.connected)
    }

    MesaText {
      id: label
      text: {
        if (!root.device) return "N/A"

        if (root.device.type === DeviceType.Wifi) return root.connected ? root.ssid : "Disconnected"

        return root.device.name
      }
    }

    TextMetrics {
      id: glyphs
      font: label.font
      text: "0123456789"
    }
  }
}

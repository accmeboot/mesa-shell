import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import qs.Services
import qs.Components

MesaSection {
  id: root

  property var nodes: []
  property PwNode defaultNode: null
  property string icon: "audio-volume-high"
  property string mutedIcon: "audio-volume-muted"

  signal nodeSelected(PwNode node)

  visible: root.nodes.length > 0

  Repeater {
    model: root.nodes

    MesaRow {
      id: device

      required property PwNode modelData

      readonly property bool current: device.modelData === root.defaultNode
      readonly property color contentColor: device.current ? ThemeService.colors.background : ThemeService.colors.foreground

      label: AudioService.nodeName(device.modelData)
      labelColor: device.contentColor
      color: device.current ? ThemeService.colors.highlight : "transparent"
      interactive: !device.current

      onClicked: root.nodeSelected(device.modelData)

      MesaIcon {
        Layout.alignment: Qt.AlignVCenter

        name: AudioService.deviceIcon(device.modelData)
        size: ConfigService.iconSize
        color: device.contentColor
      }
    }
  }

  AudioNodeRow {
    node: root.defaultNode
    showName: false
    icon: root.icon
    mutedIcon: root.mutedIcon
  }
}

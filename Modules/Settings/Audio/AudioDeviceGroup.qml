import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import qs.Services
import qs.Components
import qs.Modules.Settings.Common

PanelSection {
  id: root

  property var nodes: []
  property PwNode defaultNode: null
  property string icon: "volume"
  property string mutedIcon: "volume-mute"

  signal nodeSelected(PwNode node)

  visible: root.nodes.length > 0

  MesaDropdown {
    Layout.leftMargin: ConfigService.spacing
    Layout.rightMargin: ConfigService.spacing

    options: root.nodes.map(node => ({
      text: AudioService.nodeName(node),
      icon: AudioService.deviceIcon(node),
      value: node
    }))
    current: root.defaultNode
    placeholder: "No device"

    onSelected: value => root.nodeSelected(value)
  }

  Repeater {
    model: root.defaultNode ? [root.defaultNode] : []

    AudioNodeRow {
      required property PwNode modelData

      node: modelData
      showName: false
      icon: root.icon
      mutedIcon: root.mutedIcon
    }
  }
}

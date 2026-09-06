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
  property bool selectable: true
  property string icon: "volume"
  property string mutedIcon: "volume-mute"

  signal nodeActivated(PwNode node)

  visible: root.nodes.length > 0

  Repeater {
    model: root.nodes

    AudioNodeRow {
      required property PwNode modelData

      node: modelData
      isDefault: root.defaultNode === modelData
      selectable: root.selectable
      icon: root.icon
      mutedIcon: root.mutedIcon

      onActivated: root.nodeActivated(modelData)
    }
  }
}

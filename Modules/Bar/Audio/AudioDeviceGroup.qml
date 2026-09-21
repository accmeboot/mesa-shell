import QtQuick
import Quickshell.Services.Pipewire

import qs.Components

MesaSection {
  id: root

  property var nodes: []
  property PwNode defaultNode: null

  signal nodeSelected(PwNode node)

  visible: root.nodes.length > 0

  Repeater {
    model: root.nodes

    AudioNodeRow {
      required property PwNode modelData

      node: modelData
      selectable: true
      current: modelData === root.defaultNode

      onSelected: root.nodeSelected(modelData)
    }
  }
}

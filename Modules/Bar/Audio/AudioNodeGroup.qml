import QtQuick
import Quickshell.Services.Pipewire

import qs.Components

MesaSection {
  id: root

  property var nodes: []

  visible: root.nodes.length > 0

  Repeater {
    model: root.nodes

    AudioNodeRow {
      required property PwNode modelData

      node: modelData
    }
  }
}

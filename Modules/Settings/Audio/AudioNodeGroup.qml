import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import qs.Services
import qs.Components
import qs.Modules.Settings.Common

PanelSection {
  id: root

  property var nodes: []
  property string icon: "audio-volume-high"
  property string mutedIcon: "audio-volume-muted"

  visible: root.nodes.length > 0

  Repeater {
    model: root.nodes

    AudioNodeRow {
      required property PwNode modelData

      node: modelData
      icon: root.icon
      mutedIcon: root.mutedIcon
    }
  }
}

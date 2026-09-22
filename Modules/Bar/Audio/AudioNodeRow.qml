import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import qs.Services
import qs.Components

MesaRow {
  id: root

  property PwNode node: null
  property bool selectable: false
  property bool current: false

  readonly property real volume: root.node?.audio?.volume ?? 0
  readonly property bool muted: root.node?.audio?.muted ?? false
  readonly property bool output: root.node?.isSink ?? true

  signal selected()

  label: AudioService.nodeName(root.node)
  interactive: true
  leading: root.selectable ? defaultIndicator : null
  menu: nodeMenu

  Component {
    id: defaultIndicator

    MesaIndicator {
      radio: true
      activeFocusOnTab: false
      checked: root.current
    }
  }

  MesaIcon {
    Layout.alignment: Qt.AlignVCenter

    name: {
      if (root.output) return root.muted ? "audio-volume-muted" : "audio-volume-high";

      return root.muted ? "audio-input-microphone-muted" : "audio-input-microphone-high";
    }
    size: ConfigService.iconSizeSmall
    color: root.contentColor
  }

  MesaChevron {}

  MesaRowMenu {
    id: nodeMenu

    MesaMenuEntry {
      visible: root.selectable
      text: "Set as default"
      enabled: !root.current

      onTriggered: root.selected()
    }

    MesaMenuEntry {
      visible: root.selectable
      isSeparator: true
    }

    MesaMenuEntry {
      text: "Mute"
      checkable: true
      checked: root.muted
      enabled: root.node !== null

      onTriggered: root.node.audio.muted = !root.node.audio.muted
    }

    MesaMenuEntry {
      text: "Volume"
      slider: true
      value: root.volume
      enabled: root.node !== null

      onAdjusted: value => root.node.audio.volume = value
    }
  }
}

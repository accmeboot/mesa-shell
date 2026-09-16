import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import qs.Services
import qs.Components

RowLayout {
  id: root

  property var nodes: []
  property PwNode defaultNode: null
  property string icon: "audio-volume-high"
  property string mutedIcon: "audio-volume-muted"
  property bool expanded: false

  readonly property alias select: select
  readonly property var options: root.nodes.map(node => ({
    text: AudioService.nodeName(node),
    icon: AudioService.deviceIcon(node),
    value: node
  }))

  signal toggled()
  signal nodeSelected(PwNode node)

  Layout.fillWidth: true
  Layout.leftMargin: ConfigService.spacing
  Layout.rightMargin: ConfigService.spacing

  spacing: Math.round(ConfigService.spacing / 2)

  TextMetrics {
    id: volumeMetrics

    font: percent.font
    text: "100%"
  }

  MesaButton {
    Layout.alignment: Qt.AlignVCenter

    enabled: root.defaultNode !== null
    icon: root.defaultNode?.audio?.muted ? root.mutedIcon : root.icon

    onClicked: {
      if (root.defaultNode) root.defaultNode.audio.muted = !root.defaultNode.audio.muted;
    }
  }

  MesaSelect {
    id: select

    Layout.preferredWidth: Math.round(ConfigService.font.size * 14)
    Layout.alignment: Qt.AlignVCenter

    options: root.options
    current: root.defaultNode
    placeholder: "No device"
    expanded: root.expanded

    onToggled: root.toggled()
  }

  MesaSlider {
    id: volume

    Layout.alignment: Qt.AlignVCenter
    Layout.fillWidth: true

    enabled: root.defaultNode !== null
    value: root.defaultNode?.audio?.volume ?? 0

    onMoved: {
      if (root.defaultNode) root.defaultNode.audio.volume = volume.value;
    }
  }

  MesaText {
    id: percent

    Layout.preferredWidth: Math.ceil(volumeMetrics.advanceWidth)
    Layout.leftMargin: Math.round(ConfigService.spacing / 2)
    Layout.alignment: Qt.AlignVCenter

    text: `${Math.round(volume.value * 100)}%`
    horizontalAlignment: Text.AlignRight
  }
}

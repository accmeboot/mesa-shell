import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import qs.Services
import qs.Components

MesaRow {
  id: root

  property PwNode node: null

  property bool showName: true
  property string icon: "audio-volume-high"
  property string mutedIcon: "audio-volume-muted"

  wideTrailing: true

  TextMetrics {
    id: volumeMetrics

    font: percent.font
    text: "100%"
  }

  MesaButton {
    Layout.alignment: Qt.AlignVCenter

    enabled: root.node !== null
    icon: root.node?.audio?.muted ? root.mutedIcon : root.icon

    onClicked: root.node.audio.muted = !root.node.audio.muted
  }

  MesaText {
    Layout.preferredWidth: Math.round(ConfigService.font.size * 10)
    Layout.alignment: Qt.AlignVCenter

    visible: root.showName
    text: AudioService.nodeName(root.node)
    elide: Text.ElideRight
  }

  MesaSlider {
    id: volume

    Layout.alignment: Qt.AlignVCenter
    Layout.fillWidth: true

    enabled: root.node !== null
    value: root.node?.audio?.volume ?? 0

    onMoved: root.node.audio.volume = volume.value
  }

  MesaText {
    id: percent

    Layout.preferredWidth: Math.ceil(volumeMetrics.advanceWidth)
    Layout.leftMargin: ConfigService.gap - ConfigService.gapSmall
    Layout.alignment: Qt.AlignVCenter

    text: `${Math.round(volume.value * 100)}%`
    horizontalAlignment: Text.AlignRight
  }
}

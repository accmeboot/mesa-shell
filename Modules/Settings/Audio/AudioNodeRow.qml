import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import qs.Services
import qs.Components

RowLayout {
  id: root

  required property PwNode node

  property bool showName: true
  property string icon: "volume"
  property string mutedIcon: "volume-mute"

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

    icon: root.node.audio.muted ? root.mutedIcon : root.icon

    onClicked: root.node.audio.muted = !root.node.audio.muted
  }

  MesaText {
    Layout.preferredWidth: Math.round(ConfigService.font.size * 14)
    Layout.alignment: Qt.AlignVCenter

    visible: root.showName
    text: AudioService.nodeName(root.node)
    elide: Text.ElideRight
  }

  MesaSlider {
    id: volume

    Layout.alignment: Qt.AlignVCenter
    Layout.fillWidth: true

    value: root.node.audio.volume

    onMoved: root.node.audio.volume = volume.value
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

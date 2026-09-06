import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import qs.Services
import qs.Components

RowLayout {
  id: root

  required property PwNode node

  property bool isDefault: false
  property bool selectable: true
  property string icon: "volume"
  property string mutedIcon: "volume-mute"

  readonly property string displayName: {
    const node = root.node;

    if (!node.isStream) return node.nickname || node.description || node.name;

    const application = node.properties["application.name"] || node.name;
    const media = node.properties["media.name"];

    return media && media !== application ? `${application}: ${media}` : application;
  }

  signal activated

  Layout.fillWidth: true
  Layout.leftMargin: ConfigService.spacing
  Layout.rightMargin: ConfigService.spacing

  spacing: Math.round(ConfigService.spacing / 2)

  TextMetrics {
    id: volumeMetrics

    font: percent.font
    text: "100%"
  }

  MesaIndicator {
    Layout.alignment: Qt.AlignVCenter

    visible: root.selectable
    radio: true
    checked: root.isDefault

    onToggled: root.activated()
  }

  MesaText {
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignVCenter

    text: root.displayName
    color: root.selectable && !root.isDefault ? ConfigService.colors.on_surface : ConfigService.colors.foreground
    elide: Text.ElideRight

    HoverHandler {
      enabled: root.selectable
      cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
      enabled: root.selectable

      onTapped: root.activated()
    }
  }

  MesaSlider {
    id: volume

    Layout.preferredWidth: Math.round(ConfigService.font.size * 8)
    Layout.alignment: Qt.AlignVCenter

    value: root.node.audio.volume

    onMoved: root.node.audio.volume = volume.value
  }

  MesaText {
    id: percent

    Layout.preferredWidth: Math.ceil(volumeMetrics.advanceWidth)
    Layout.alignment: Qt.AlignVCenter

    text: `${Math.round(volume.value * 100)}%`
    horizontalAlignment: Text.AlignRight
    color: ConfigService.colors.on_surface
  }

  MesaButton {
    Layout.alignment: Qt.AlignVCenter

    icon: root.node.audio.muted ? root.mutedIcon : root.icon
    iconSize: Math.round(ConfigService.font.size * 1.2)
    verticalPadding: Math.round(ConfigService.spacing / 2)
    contentColor: root.node.audio.muted ? ConfigService.colors.critical : ConfigService.colors.foreground

    onClicked: root.node.audio.muted = !root.node.audio.muted
  }
}

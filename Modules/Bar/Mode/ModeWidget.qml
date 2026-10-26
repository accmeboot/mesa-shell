import QtQuick

import qs.Components
import qs.Services

Rectangle {
  id: root

  readonly property string iconName: ({ resize: "resize" })[CompositorService.mode] ?? ""

  visible: CompositorService.mode !== "" && CompositorService.mode !== "default"
  color: ThemeService.colors.attention

  implicitWidth: (root.iconName ? icon.implicitWidth : label.implicitWidth) + ConfigService.space * 2
  implicitHeight: label.implicitHeight + ConfigService.space

  MesaIcon {
    id: icon

    anchors.centerIn: parent

    visible: root.iconName !== ""
    name: root.iconName
    size: ConfigService.iconSizeSmall
    color: ThemeService.colors.background
  }

  MesaText {
    id: label

    anchors.centerIn: parent

    visible: root.iconName === ""
    text: CompositorService.mode
    color: ThemeService.colors.background
  }
}

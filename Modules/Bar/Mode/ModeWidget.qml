import QtQuick

import qs.Components
import qs.Services

Rectangle {
  visible: CompositorService.mode !== "" && CompositorService.mode !== "default"
  color: ThemeService.colors.attention
  radius: ConfigService.radius

  implicitWidth: label.implicitWidth + ConfigService.space * 2
  implicitHeight: label.implicitHeight + ConfigService.space

  MesaText {
    id: label

    anchors.centerIn: parent

    text: CompositorService.mode
    color: ThemeService.colors.background
  }
}

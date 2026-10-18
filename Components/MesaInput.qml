import QtQuick
import QtQuick.Controls

import qs.Services

TextField {
  id: root

  property color borderColor: ThemeService.colors.surface
  property color backgroundColor: "transparent"
  property alias frame: frame

  color: ThemeService.colors.foreground
  font.family: ConfigService.font.name
  font.pointSize: ConfigService.font.size
  renderType: Text.NativeRendering

  placeholderTextColor: ThemeService.muted
  selectionColor: ThemeService.colors.highlight
  selectedTextColor: ThemeService.colors.background

  leftPadding: ConfigService.space
  rightPadding: ConfigService.space
  topPadding: 0
  bottomPadding: 0

  background: Rectangle {
    id: frame

    color: root.backgroundColor
    radius: ConfigService.radius
    border.color: root.borderColor
    border.width: ConfigService.border
  }

}

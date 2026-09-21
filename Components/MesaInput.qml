import QtQuick
import QtQuick.Controls

import qs.Services

TextField {
  id: root

  property color borderColor: ThemeService.colors.on_surface
  property color backgroundColor: "transparent"

  color: ThemeService.colors.foreground
  font.family: ConfigService.font.name
  font.pointSize: ConfigService.font.size
  renderType: Text.NativeRendering

  placeholderTextColor: ThemeService.colors.on_surface
  selectionColor: ThemeService.colors.highlight
  selectedTextColor: ThemeService.colors.background

  leftPadding: ConfigService.spaceMd
  rightPadding: ConfigService.spaceMd

  background: Rectangle {
    color: root.backgroundColor
    border.color: root.borderColor
    border.width: ConfigService.border
  }

}

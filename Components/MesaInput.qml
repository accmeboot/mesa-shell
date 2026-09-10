import QtQuick
import QtQuick.Controls

import qs.Services

TextField {
  id: root

  property color borderColor: ThemeService.colors.on_surface

  color: ThemeService.colors.foreground
  font.family: ConfigService.font.name
  font.pointSize: ConfigService.font.size
  renderType: Text.NativeRendering

  placeholderTextColor: ThemeService.colors.on_surface
  selectionColor: ThemeService.colors.highlight
  selectedTextColor: ThemeService.colors.background

  leftPadding: ConfigService.spacing
  rightPadding: ConfigService.spacing

  background: Rectangle {
    color: "transparent"
    border.color: root.borderColor
    border.width: ConfigService.border
  }
}

import QtQuick
import QtQuick.Controls

import qs.Services

Control {
  padding: ConfigService.popupInset
  hoverEnabled: false

  background: Rectangle {
    color: ThemeService.colors.background
    radius: ConfigService.radius > 0 ? ConfigService.radius + ConfigService.popupInset : 0
    border.color: ThemeService.colors.on_surface
    border.width: ConfigService.border
  }
}

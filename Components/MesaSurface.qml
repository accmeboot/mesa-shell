import QtQuick
import QtQuick.Controls

import qs.Services

Control {
  id: root

  property real minimumWidth: 0
  property real maximumWidth: Infinity

  implicitWidth: Math.max(root.minimumWidth, Math.min(root.maximumWidth, root.implicitContentWidth + root.padding * 2))

  padding: ConfigService.popupInset
  hoverEnabled: false

  background: Rectangle {
    color: ThemeService.colors.background
    border.color: ThemeService.colors.on_surface
    border.width: ConfigService.border
  }
}

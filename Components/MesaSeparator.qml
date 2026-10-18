import QtQuick

import qs.Services

Item {
  implicitHeight: ConfigService.border + ConfigService.popupPadding * 2

  Rectangle {
    x: -ConfigService.popupPadding
    width: parent.width + ConfigService.popupPadding * 2
    height: ConfigService.border
    anchors.verticalCenter: parent.verticalCenter
    color: ThemeService.colors.on_surface
  }
}

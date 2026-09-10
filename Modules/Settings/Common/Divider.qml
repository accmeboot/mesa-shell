import QtQuick
import QtQuick.Layouts

import qs.Services

Rectangle {
  Layout.fillWidth: true

  implicitHeight: ConfigService.border
  color: ThemeService.colors.on_surface
}

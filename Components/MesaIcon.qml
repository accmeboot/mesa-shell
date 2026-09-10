import QtQuick
import Qt5Compat.GraphicalEffects

import qs.Services

Item {
  id: root
  property string name
  property int size: ConfigService.font.size
  property color color: ThemeService.colors.foreground

  implicitWidth: root.size
  implicitHeight: root.size

  Image {
    id: icon
    anchors.fill: parent
    source: `root:/assets/${root.name}.svg`
    sourceSize: Qt.size(root.size, root.size)
  }

  ColorOverlay {
    anchors.fill: parent
    source: icon
    color: root.color
  }
}

import QtQuick
import QtQuick.Effects

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
    source: root.name === "" ? "" : `root:/assets/${root.name}.svg`
    sourceSize: Qt.size(root.size, root.size)
    visible: false
    layer.enabled: true
  }

  Rectangle {
    id: fill
    anchors.fill: parent
    color: root.color
    visible: false
    layer.enabled: true
  }

  MultiEffect {
    anchors.fill: parent
    source: fill
    maskEnabled: true
    maskSource: icon
    maskThresholdMin: 0.5
    maskSpreadAtMin: 1.0
  }
}

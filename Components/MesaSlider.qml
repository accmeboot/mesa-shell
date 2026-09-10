import QtQuick
import QtQuick.Controls

import qs.Services

Slider {
  id: root

  readonly property int handleSize: Math.round(ConfigService.font.size * 1.0)
  readonly property int trackSize: Math.max(ConfigService.border, Math.round(root.handleSize / 3))

  from: 0
  to: 1
  stepSize: 0.01

  background: Item {
    implicitWidth: Math.round(ConfigService.font.size * 10)
    implicitHeight: Math.round(ConfigService.font.size * 1.5)

    Rectangle {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter

      height: root.trackSize
      color: ThemeService.colors.on_surface

      Rectangle {
        width: root.visualPosition * parent.width
        height: parent.height

        color: ThemeService.colors.highlight
      }
    }
  }

  handle: Rectangle {
    x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
    y: root.topPadding + Math.round((root.availableHeight - height) / 2)

    implicitWidth: root.handleSize
    implicitHeight: root.handleSize
    radius: width / 2

    color: ThemeService.colors.foreground
  }

  HoverHandler {
    cursorShape: Qt.PointingHandCursor
  }

  // WheelHandler never receives events on this shell's layer-shell windows;
  // MouseArea does, so the wheel is handled here instead.
  MouseArea {
    id: wheelArea

    property real notches: 0

    anchors.fill: parent
    acceptedButtons: Qt.NoButton

    onWheel: wheel => {
      const previous = root.value;

      wheelArea.notches += wheel.angleDelta.y / 120;

      while (wheelArea.notches >= 1) {
        wheelArea.notches -= 1;
        root.increase();
      }

      while (wheelArea.notches <= -1) {
        wheelArea.notches += 1;
        root.decrease();
      }

      if (root.value !== previous) root.moved();
    }
  }
}

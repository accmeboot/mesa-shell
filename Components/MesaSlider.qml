import QtQuick
import QtQuick.Controls

import qs.Services
import qs.Components

Slider {
  id: root

  property string text: ""

  from: 0
  to: 1

  background: Item {
    implicitWidth: 140
    implicitHeight: Math.round(ConfigService.font.size + ConfigService.spacing)

    Rectangle {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter

      implicitHeight: parent.implicitHeight

      color: ConfigService.colors.on_surface

      Rectangle {
        width: root.visualPosition * parent.width
        height: parent.height

        color: ConfigService.colors.highlight
      }

      MesaText {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: ConfigService.spacing
        anchors.rightMargin: ConfigService.spacing

        text: root.text
        elide: Text.ElideRight

        color: ConfigService.colors.background
      }
    }
  }

  handle: Rectangle {
    implicitWidth: 0
    implicitHeight: 0
    radius: 0
  }

  HoverHandler {
    cursorShape: Qt.PointingHandCursor
  }
}

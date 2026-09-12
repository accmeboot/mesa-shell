import QtQuick

import qs.Services

Item {
  id: root

  property bool checked: false
  property bool radio: false
  property color color: {
    if (!root.enabled) return ThemeService.colors.on_surface;
    return root.checked ? ThemeService.colors.ok : ThemeService.colors.foreground;
  }
  property color backgroundColor: ThemeService.colors.background

  readonly property int trackHeight: Math.round(ConfigService.font.size * 1.25)
  readonly property int knobInset: Math.max(ConfigService.border * 2, Math.round(root.trackHeight / 6))

  signal toggled

  implicitWidth: root.radio ? radioIcon.implicitWidth : root.trackHeight * 2
  implicitHeight: root.radio ? radioIcon.implicitHeight : root.trackHeight

  MesaIcon {
    id: radioIcon

    anchors.centerIn: parent
    visible: root.radio
    name: root.checked ? "system-suspend-hibernate" : "draw-circle"
    size: Math.round(ConfigService.font.size * 1.35)
    color: root.color
  }

  Rectangle {
    anchors.fill: parent
    visible: !root.radio
    radius: height / 2
    color: root.checked ? root.color : "transparent"
    border.width: ConfigService.border
    border.color: root.color

    Rectangle {
      x: root.checked ? parent.width - width - root.knobInset : root.knobInset
      anchors.verticalCenter: parent.verticalCenter
      width: parent.height - root.knobInset * 2
      height: width
      radius: width / 2
      color: root.checked ? root.backgroundColor : root.color
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: root.toggled()
  }
}

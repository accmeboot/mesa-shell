import QtQuick

import qs.Services

Rectangle {
  id: root

  property string text
  property string icon
  property int iconSize: Math.round(ConfigService.font.size * 1.5)
  property color contentColor: ThemeService.colors.foreground
  property int maximumContentWidth: 0
  property int horizontalPadding: ConfigService.spacing
  property int verticalPadding: ConfigService.spacing
  property alias acceptedButtons: mouseArea.acceptedButtons

  readonly property color effectiveContentColor: root.enabled ? root.contentColor : ThemeService.colors.on_surface

  signal clicked(var mouse)

  implicitWidth: (root.icon ? iconLoader.implicitWidth : label.width) + root.horizontalPadding
  implicitHeight: (root.icon ? iconLoader.implicitHeight : label.implicitHeight) + root.verticalPadding
  color: ThemeService.colors.surface

  border.color: ThemeService.colors.on_surface
  border.width: ConfigService.border

  MesaText {
    id: label
    visible: !root.icon
    anchors.centerIn: parent
    width: root.maximumContentWidth > 0 ? Math.min(label.implicitWidth, root.maximumContentWidth) : label.implicitWidth
    text: root.text
    color: root.effectiveContentColor
    elide: Text.ElideRight
    textFormat: Text.StyledText
  }

  Loader {
    id: iconLoader
    anchors.centerIn: parent
    active: root.icon !== ""

    sourceComponent: MesaIcon {
      name: root.icon
      size: root.iconSize
      color: root.effectiveContentColor
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: mouse => root.clicked(mouse)
  }
}

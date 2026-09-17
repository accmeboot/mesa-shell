import QtQuick

import qs.Services

Rectangle {
  id: root

  property string text
  property string icon
  property int iconSize: ConfigService.iconSize
  property color contentColor: ThemeService.colors.foreground
  property color disabledContentColor: ThemeService.colors.on_surface
  property int maximumContentWidth: 0
  property int horizontalPadding: ConfigService.gap
  property int verticalPadding: ConfigService.gap
  property alias acceptedButtons: mouseArea.acceptedButtons

  readonly property color effectiveContentColor: root.enabled ? root.contentColor : root.disabledContentColor
  readonly property real contentWidth: Math.ceil(root.maximumContentWidth > 0 ? Math.min(label.implicitWidth, root.maximumContentWidth) : label.implicitWidth)

  signal clicked(var mouse)

  implicitWidth: (root.icon ? iconLoader.implicitWidth : root.contentWidth) + root.horizontalPadding * 2
  implicitHeight: (root.icon ? iconLoader.implicitHeight : label.implicitHeight) + root.verticalPadding
  color: ThemeService.colors.surface

  border.color: ThemeService.colors.on_surface
  border.width: ConfigService.border

  MesaText {
    id: label
    visible: !root.icon
    anchors.centerIn: parent
    width: Math.max(0, Math.min(root.contentWidth, root.width - root.horizontalPadding * 2))
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
    cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    onClicked: mouse => root.clicked(mouse)
  }
}

import QtQuick

import qs.Services

Rectangle {
  id: root

  property string text
  property string icon
  property int iconSize: ConfigService.iconSize
  property color accent: "transparent"
  property color contentColor: root.accented ? ThemeService.colors.background : ThemeService.colors.foreground
  property color disabledContentColor: root.accented ? ThemeService.colors.background : ThemeService.colors.on_surface
  property int maximumContentWidth: 0
  property int horizontalPadding: ConfigService.gap
  property int verticalPadding: ConfigService.gap
  property alias acceptedButtons: mouseArea.acceptedButtons

  readonly property bool accented: root.accent.a > 0
  readonly property color effectiveContentColor: root.enabled ? root.contentColor : root.disabledContentColor
  readonly property real contentWidth: Math.ceil(root.maximumContentWidth > 0 ? Math.min(label.implicitWidth, root.maximumContentWidth) : label.implicitWidth)

  signal clicked(var mouse)

  implicitWidth: (root.icon ? iconLoader.implicitWidth : root.contentWidth) + root.horizontalPadding * 2
  implicitHeight: (root.icon ? iconLoader.implicitHeight : label.implicitHeight) + root.verticalPadding
  color: root.accented ? (root.enabled ? root.accent : ThemeService.colors.attention) : ThemeService.colors.surface

  border.color: ThemeService.colors.on_surface
  border.width: ConfigService.border

  activeFocusOnTab: root.enabled

  Keys.onReturnPressed: root.clicked({ button: Qt.LeftButton })
  Keys.onEnterPressed: root.clicked({ button: Qt.LeftButton })
  Keys.onSpacePressed: root.clicked({ button: Qt.LeftButton })

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
    onPressed: root.forceActiveFocus(Qt.MouseFocusReason)
    onClicked: mouse => root.clicked(mouse)
  }

  MesaFocusRing {
    padding: ConfigService.border * 2
  }
}

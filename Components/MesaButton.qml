import QtQuick

import qs.Services

Rectangle {
  id: root

  property string text
  property string icon
  property int iconSize: ConfigService.iconSize
  property color accent: "transparent"
  property color contentColor: root.accented ? ThemeService.colors.background : ThemeService.colors.foreground
  property color disabledContentColor: root.accented ? ThemeService.colors.background : ThemeService.disabled
  property bool open: false
  property bool labelVisible: true

  property int maximumContentWidth: 0
  property int horizontalPadding: ConfigService.spaceMd
  property int verticalPadding: ConfigService.spaceMd
  property alias acceptedButtons: mouseArea.acceptedButtons

  readonly property bool accented: root.accent.a > 0
  readonly property color effectiveContentColor: root.enabled ? root.contentColor : root.disabledContentColor
  readonly property real contentWidth: Math.ceil(root.maximumContentWidth > 0 ? Math.min(label.implicitWidth, root.maximumContentWidth) : label.implicitWidth)

  signal clicked(var mouse)

  implicitWidth: (root.icon ? iconLoader.implicitWidth : root.contentWidth) + root.horizontalPadding * 2
  implicitHeight: (root.icon ? iconLoader.implicitHeight : label.implicitHeight) + root.verticalPadding
  color: {
    if (root.accented) return root.enabled ? root.accent : ThemeService.colors.attention;

    return root.open ? ThemeService.colors.surface : "transparent";
  }

  border.color: ThemeService.colors.on_surface
  border.width: 0

  activeFocusOnTab: root.enabled

  Keys.onReturnPressed: root.clicked({ button: Qt.LeftButton })
  Keys.onEnterPressed: root.clicked({ button: Qt.LeftButton })
  Keys.onSpacePressed: root.clicked({ button: Qt.LeftButton })

  MesaMarquee {
    id: label
    visible: !root.icon && root.labelVisible
    anchors.centerIn: parent
    width: Math.max(0, Math.min(root.contentWidth, root.width - root.horizontalPadding * 2))
    text: root.text
    color: root.effectiveContentColor
    textFormat: Text.StyledText
    running: label.visible && (root.open || root.activeFocus || mouseArea.containsMouse)
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

}

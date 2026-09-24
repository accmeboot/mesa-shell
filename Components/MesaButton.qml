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
  property bool flat: false
  property bool open: false
  property bool underlined: false
  property color underlineColor: ThemeService.colors.highlight
  readonly property var row: {
    for (let item = root.parent; item; item = item.parent) {
      if (item.surfaceColor !== undefined) return item;
    }

    return null;
  }

  property int maximumContentWidth: 0
  property int horizontalPadding: ConfigService.spaceMd
  property int verticalPadding: ConfigService.spaceMd
  property alias acceptedButtons: mouseArea.acceptedButtons

  readonly property bool accented: root.accent.a > 0
  readonly property bool inverted: root.flat && root.activeFocus
  readonly property color rowContent: root.row ? root.row.contentColor : ThemeService.colors.foreground
  readonly property color rowSurface: root.row ? root.row.surfaceColor : ThemeService.colors.background
  readonly property color rowAccent: root.row ? root.row.accentColor : ThemeService.colors.highlight
  readonly property color effectiveContentColor: {
    if (!root.flat) return root.enabled ? root.contentColor : root.disabledContentColor;
    if (!root.enabled) return ThemeService.colors.on_surface;

    return root.inverted ? root.rowSurface : root.rowContent;
  }
  readonly property real contentWidth: Math.ceil(root.maximumContentWidth > 0 ? Math.min(label.implicitWidth, root.maximumContentWidth) : label.implicitWidth)

  signal clicked(var mouse)

  implicitWidth: (root.icon ? iconLoader.implicitWidth : root.contentWidth) + root.horizontalPadding * 2
  implicitHeight: (root.icon ? iconLoader.implicitHeight : label.implicitHeight) + root.verticalPadding
  color: {
    if (root.flat) return root.inverted ? root.rowAccent : "transparent";
    if (root.accented) return root.enabled ? root.accent : ThemeService.colors.attention;

    return root.open ? ThemeService.colors.surface : "transparent";
  }

  border.color: ThemeService.colors.on_surface
  border.width: 0

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

  Rectangle {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.bottomMargin: ConfigService.border
    height: ConfigService.border * 2
    visible: root.underlined
    color: root.underlineColor
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

import QtQuick

import qs.Services

Item {
  id: root

  property bool checked: false
  property bool radio: false
  readonly property var row: {
    for (let item = root.parent; item; item = item.parent) {
      if (item.surfaceColor !== undefined) return item;
    }

    return null;
  }

  property color color: {
    if (!root.enabled) return ThemeService.colors.on_surface;

    return root.row ? root.row.contentColor : ThemeService.colors.foreground;
  }
  property color backgroundColor: root.row ? root.row.surfaceColor : ThemeService.colors.background

  readonly property int trackHeight: ConfigService.iconSizeSmall
  readonly property int knobInset: Math.max(ConfigService.border * 2, Math.round(root.trackHeight / 6))

  signal toggled

  implicitWidth: root.radio ? root.trackHeight : root.trackHeight * 2
  implicitHeight: root.trackHeight

  activeFocusOnTab: root.enabled

  Keys.onReturnPressed: root.toggled()
  Keys.onEnterPressed: root.toggled()
  Keys.onSpacePressed: root.toggled()

  Rectangle {
    anchors.centerIn: parent
    visible: root.radio && root.checked
    width: parent.width - root.knobInset * 2
    height: width
    color: root.color
  }

  Rectangle {
    anchors.fill: parent
    visible: !root.radio
    color: root.color

    Rectangle {
      x: root.checked ? parent.width - width - root.knobInset : root.knobInset
      anchors.verticalCenter: parent.verticalCenter
      width: parent.height - root.knobInset * 2
      height: width
      color: root.backgroundColor
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    onPressed: root.forceActiveFocus(Qt.MouseFocusReason)
    onClicked: root.toggled()
  }

}

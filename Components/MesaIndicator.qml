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

  property color color: root.enabled ? root.row?.foreground ?? ThemeService.colors.foreground : ThemeService.disabled
  readonly property color accent: root.row?.highlighted ? root.color : ThemeService.colors.highlight

  readonly property int handleSize: Math.round(ConfigService.font.size * 1.0)
  readonly property int trackSize: Math.max(ConfigService.border, Math.round(root.handleSize / 6))

  signal toggled

  implicitWidth: root.radio ? root.handleSize : root.handleSize * 2
  implicitHeight: root.handleSize

  activeFocusOnTab: root.enabled

  Keys.onReturnPressed: root.toggled()
  Keys.onEnterPressed: root.toggled()
  Keys.onSpacePressed: root.toggled()

  Rectangle {
    anchors.fill: parent
    visible: root.radio && root.checked
    color: root.color
  }

  Item {
    anchors.fill: parent
    visible: !root.radio

    Rectangle {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      height: root.trackSize
      color: root.checked ? root.accent : Qt.alpha(root.color, 0.3)
    }

    Rectangle {
      x: root.checked ? parent.width - width : 0
      width: parent.height
      height: width
      color: root.color
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    onPressed: root.forceActiveFocus(Qt.MouseFocusReason)
    onClicked: root.toggled()
  }

}

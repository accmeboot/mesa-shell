import QtQuick

import qs.Services

Item {
  id: root

  property Item target: root.parent
  property bool active: root.target?.activeFocus ?? false
  property int padding: 0
  property int horizontalPadding: root.padding
  property int verticalPadding: root.padding

  function navigable(): bool {
    for (let item = root.target; item; item = item.parent) {
      if (item.navigable !== undefined) return item.navigable;
    }

    return false;
  }

  anchors.fill: root.target
  anchors.leftMargin: -root.horizontalPadding
  anchors.rightMargin: -root.horizontalPadding
  anchors.topMargin: -root.verticalPadding
  anchors.bottomMargin: -root.verticalPadding

  visible: root.active && root.navigable()

  Rectangle {
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: parent.right

    color: "transparent"
    border.width: ConfigService.border
    border.color: ThemeService.colors.highlight
  }
}

import QtQuick

import qs.Services

Item {
  id: root

  property Item target: root.parent
  property bool active: root.target?.activeFocus ?? false
  property int padding: 0

  function navigable(): bool {
    for (let item = root.target; item; item = item.parent) {
      if (item.navigable !== undefined) return item.navigable;
    }

    return false;
  }

  anchors.fill: root.target
  anchors.margins: -root.padding

  visible: root.active && root.navigable()

  Rectangle {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom

    height: ConfigService.border * 2
    color: ThemeService.colors.highlight
  }
}

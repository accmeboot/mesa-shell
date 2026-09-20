import QtQuick

import qs.Services

Item {
  id: root

  property Item target: root.parent
  property int padding: 0

  readonly property int armLength: Math.max(ConfigService.border * 2, Math.round(Math.min(ConfigService.gap, root.width / 3, root.height / 3)))

  function navigable(): bool {
    for (let item = root.target; item; item = item.parent) {
      if (item.navigable !== undefined) return item.navigable;
    }

    return false;
  }

  anchors.fill: root.target
  anchors.margins: -root.padding

  visible: (root.target?.activeFocus ?? false) && root.navigable()

  Repeater {
    model: [[0, 0], [1, 0], [0, 1], [1, 1]]

    Item {
      id: corner

      required property var modelData

      x: corner.modelData[0] ? root.width - corner.width : 0
      y: corner.modelData[1] ? root.height - corner.height : 0
      width: root.armLength
      height: root.armLength

      Rectangle {
        y: corner.modelData[1] ? corner.height - height : 0
        width: corner.width
        height: ConfigService.border
        color: ThemeService.colors.highlight
      }

      Rectangle {
        x: corner.modelData[0] ? corner.width - width : 0
        width: ConfigService.border
        height: corner.height
        color: ThemeService.colors.highlight
      }
    }
  }
}

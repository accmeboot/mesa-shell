import QtQuick

import qs.Services

Rectangle {
  id: root

  property Item target: root.parent
  property int padding: 0

  function navigable(): bool {
    for (let item = root.target; item; item = item.parent) {
      if (item.navigable !== undefined) return item.navigable;
    }

    return false;
  }

  anchors.fill: root.target
  anchors.margins: -root.padding

  visible: (root.target?.activeFocus ?? false) && root.navigable()
  color: "transparent"

  border.color: ThemeService.colors.highlight
  border.width: ConfigService.border
}

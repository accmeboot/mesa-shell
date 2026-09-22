import QtQuick
import QtQuick.Layouts

import qs.Services

MesaIcon {
  id: root

  readonly property var row: {
    for (let item = root.parent; item; item = item.parent) {
      if (item.surfaceColor !== undefined) return item;
    }

    return null;
  }

  Layout.alignment: Qt.AlignVCenter

  color: root.row ? root.row.contentColor : ThemeService.colors.foreground
  name: "pan-end"
  size: ConfigService.iconSizeSmall
}

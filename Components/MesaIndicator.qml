import QtQuick

import qs.Services

MesaIcon {
  id: root

  property bool checked: false
  property bool radio: false

  signal toggled

  name: {
    if (root.radio) return root.checked ? "system-suspend-hibernate" : "draw-circle";
    return root.checked ? "view-task" : "draw-rectangle";
  }
  size: Math.round(root.radio ? ConfigService.font.size * 1.35 : ConfigService.font.size * 1.5)
  color: {
    if (!root.enabled) return ThemeService.colors.on_surface;
    return root.checked ? ThemeService.colors.ok : ThemeService.colors.foreground;
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: root.toggled()
  }
}

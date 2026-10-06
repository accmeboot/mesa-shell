import QtQuick
import QtQuick.Layouts

import qs.Services

ColumnLayout {
  id: root

  readonly property bool first: root.parent ? root.parent.visibleChildren[0] === root : false

  Layout.fillWidth: true

  spacing: 0

  Rectangle {
    Layout.fillWidth: true

    visible: !root.first
    implicitHeight: ConfigService.border
    color: ThemeService.colors.on_surface
  }
}

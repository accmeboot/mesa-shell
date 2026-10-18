import QtQuick
import QtQuick.Layouts

ColumnLayout {
  id: root

  readonly property bool first: root.parent ? root.parent.visibleChildren[0] === root : false

  Layout.fillWidth: true

  spacing: 0

  MesaSeparator {
    Layout.fillWidth: true

    visible: !root.first
  }
}

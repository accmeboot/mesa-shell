import QtQuick
import QtQuick.Layouts

import qs.Services

ColumnLayout {
  id: root

  property string title

  readonly property bool first: root.parent ? root.parent.visibleChildren[0] === root : false

  default property alias content: body.data

  Layout.fillWidth: true

  spacing: 0

  Rectangle {
    Layout.fillWidth: true

    visible: root.title !== ""
    implicitWidth: headerRow.implicitWidth + ConfigService.spaceMd * 2
    implicitHeight: headerRow.implicitHeight + ConfigService.spaceSm * 2
    color: "transparent"

    Rectangle {
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right

      visible: !root.first
      height: ConfigService.border
      color: ThemeService.colors.on_surface
    }

    Rectangle {
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.right: parent.right

      height: ConfigService.border
      color: ThemeService.colors.on_surface
    }

    RowLayout {
      id: headerRow

      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: ConfigService.spaceMd
      anchors.rightMargin: ConfigService.spaceMd

      spacing: ConfigService.spaceMd

      MesaText {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter

        text: root.title
        color: ThemeService.muted
        font.bold: true
        font.capitalization: Font.AllUppercase
        font.letterSpacing: 1
        font.pointSize: Math.max(1, ConfigService.font.size - 1)
        elide: Text.ElideRight
      }
    }
  }

  ColumnLayout {
    id: body

    Layout.fillWidth: true

    spacing: 0
  }
}

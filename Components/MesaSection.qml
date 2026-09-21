import QtQuick
import QtQuick.Layouts

import qs.Services

ColumnLayout {
  id: root

  property string title

  default property alias content: body.data

  Layout.fillWidth: true

  spacing: 0

  Rectangle {
    Layout.fillWidth: true

    visible: root.title !== ""
    implicitWidth: headerRow.implicitWidth + ConfigService.spaceMd * 2
    implicitHeight: headerRow.implicitHeight + ConfigService.spaceSm * 2
    color: ThemeService.colors.surface

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
        color: ThemeService.colors.foreground
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

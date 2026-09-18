import QtQuick
import QtQuick.Layouts

import qs.Services

ColumnLayout {
  id: root

  property string title

  default property alias content: body.data
  property alias actions: headerActions.data

  Layout.fillWidth: true

  spacing: body.implicitHeight > 0 ? ConfigService.gapSmall : 0

  Item {
    Layout.fillWidth: true

    visible: root.title !== ""
    implicitHeight: Math.max(headerRow.implicitHeight + ConfigService.padding * 2, ConfigService.controlHeight)

    RowLayout {
      id: headerRow

      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: ConfigService.gap
      anchors.rightMargin: ConfigService.gap

      spacing: ConfigService.gap

      MesaText {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter

        text: root.title
        color: ThemeService.colors.attention
        font.bold: true
        elide: Text.ElideRight
      }

      RowLayout {
        id: headerActions

        Layout.alignment: Qt.AlignVCenter

        visible: headerActions.children.length > 0
        spacing: ConfigService.gapSmall
      }
    }
  }

  ColumnLayout {
    id: body

    Layout.fillWidth: true

    spacing: ConfigService.gapSmall
  }
}

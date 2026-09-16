import QtQuick
import QtQuick.Layouts

import qs.Services

ColumnLayout {
  id: root

  property string title

  default property alias content: body.data
  property alias actions: headerActions.data

  Layout.fillWidth: true

  spacing: body.visibleChildren.length > 0 ? Math.round(ConfigService.spacing / 2) : 0

  Item {
    Layout.fillWidth: true

    visible: root.title !== ""
    implicitHeight: headerRow.implicitHeight + ConfigService.spacing

    RowLayout {
      id: headerRow

      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: ConfigService.spacing
      anchors.rightMargin: ConfigService.spacing

      spacing: ConfigService.spacing

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
        spacing: Math.round(ConfigService.spacing / 2)
      }
    }
  }

  ColumnLayout {
    id: body

    Layout.fillWidth: true

    spacing: Math.round(ConfigService.spacing / 2)
  }
}

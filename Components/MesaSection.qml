import QtQuick
import QtQuick.Layouts

import qs.Services

ColumnLayout {
  id: root

  property string title

  default property alias content: body.data

  Layout.fillWidth: true

  spacing: body.visibleChildren.length > 0 ? Math.round(ConfigService.spacing / 2) : 0

  Item {
    Layout.fillWidth: true

    visible: root.title !== ""
    implicitHeight: header.implicitHeight + ConfigService.spacing

    MesaText {
      id: header

      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: ConfigService.spacing
      anchors.rightMargin: ConfigService.spacing

      text: root.title
      color: ThemeService.colors.attention
      font.bold: true
      elide: Text.ElideRight
    }
  }

  ColumnLayout {
    id: body

    Layout.fillWidth: true

    spacing: Math.round(ConfigService.spacing / 2)
  }
}

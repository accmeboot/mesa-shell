import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

Rectangle {
  id: root

  property string message
  property bool open: false

  signal confirmed
  signal cancelled

  Layout.fillWidth: true

  visible: root.open
  implicitHeight: row.implicitHeight + ConfigService.spacing + ConfigService.border
  color: ThemeService.colors.background

  Rectangle {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top

    implicitHeight: ConfigService.border
    color: ThemeService.colors.on_surface
  }

  RowLayout {
    id: row

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: ConfigService.spacing
    anchors.rightMargin: ConfigService.spacing

    spacing: ConfigService.spacing

    MesaText {
      Layout.fillWidth: true

      text: root.message
      elide: Text.ElideRight
    }

    MesaButton {
      icon: "window-close"
      color: ThemeService.colors.highlight
      contentColor: ThemeService.colors.background

      onClicked: root.cancelled()
    }

    MesaButton {
      icon: "dialog-ok"
      color: ThemeService.colors.critical
      contentColor: ThemeService.colors.background

      onClicked: root.confirmed()
    }
  }
}

import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

ColumnLayout {
  id: root

  property string title
  property string view: ""
  property bool filled: false

  default property alias content: body.data

  readonly property bool navigable: root.view !== ""
  readonly property color baseColor: root.filled ? ConfigService.colors.surface : "transparent"

  Layout.fillWidth: true

  spacing: Math.round(ConfigService.spacing / 2)

  Rectangle {
    Layout.fillWidth: true

    implicitHeight: header.implicitHeight + ConfigService.spacing
    color: root.baseColor

    HoverHandler {
      enabled: root.navigable
      cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
      enabled: root.navigable

      onTapped: SettingsService.navigate(root.view)
    }

    RowLayout {
      id: header

      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: ConfigService.spacing
      anchors.rightMargin: ConfigService.spacing

      spacing: ConfigService.spacing

      MesaText {
        Layout.fillWidth: true

        text: root.title
        font.bold: true
      }

      MesaIcon {
        visible: root.navigable
        name: "arrow-right"
        size: Math.round(ConfigService.font.size * 1.2)
        color: ConfigService.colors.foreground
      }
    }
  }

  ColumnLayout {
    id: body

    Layout.fillWidth: true

    spacing: Math.round(ConfigService.spacing / 2)
  }
}

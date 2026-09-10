import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

ColumnLayout {
  id: root

  property string title
  property string value
  property color valueColor: ThemeService.colors.on_surface
  property string view: ""

  default property alias content: body.data

  readonly property bool navigable: root.view !== ""

  Layout.fillWidth: true

  spacing: body.visibleChildren.length > 0 ? Math.round(ConfigService.spacing / 2) : 0

  Rectangle {
    Layout.fillWidth: true

    implicitHeight: header.implicitHeight + ConfigService.spacing
    color: root.navigable && hover.hovered ? ThemeService.colors.surface : "transparent"

    HoverHandler {
      id: hover

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
        elide: Text.ElideRight
      }

      MesaText {
        Layout.alignment: Qt.AlignVCenter
        Layout.maximumWidth: Math.round(ConfigService.font.size * 12)

        visible: root.value !== ""
        text: root.value
        color: root.valueColor
        elide: Text.ElideRight
      }

      MesaIcon {
        Layout.alignment: Qt.AlignVCenter

        visible: root.navigable
        name: "pan-end"
        size: Math.round(ConfigService.font.size * 1.2)
        color: ThemeService.colors.foreground
      }
    }
  }

  ColumnLayout {
    id: body

    Layout.fillWidth: true

    spacing: Math.round(ConfigService.spacing / 2)
  }
}

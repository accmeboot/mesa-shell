import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

Rectangle {
  id: root

  property string label
  property string sublabel
  property string view: ""
  property bool active: false

  readonly property bool navigable: root.view !== ""
  readonly property color contentColor: {
    const colors = ConfigService.colors;

    if (!root.enabled) return colors.on_surface;

    return root.active ? colors.background : colors.foreground;
  }

  Layout.fillWidth: true

  implicitHeight: body.implicitHeight + ConfigService.spacing * 2
  color: root.active ? ConfigService.colors.highlight : ConfigService.colors.surface

  border.color: ConfigService.colors.on_surface
  border.width: ConfigService.border

  HoverHandler {
    enabled: root.navigable
    cursorShape: Qt.PointingHandCursor
  }

  TapHandler {
    enabled: root.navigable

    onTapped: SettingsService.navigate(root.view)
  }

  ColumnLayout {
    id: body

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: ConfigService.spacing
    anchors.rightMargin: ConfigService.spacing

    spacing: 0

    RowLayout {
      Layout.fillWidth: true

      spacing: Math.round(ConfigService.spacing / 2)

      MesaText {
        Layout.fillWidth: true

        text: root.label
        color: root.contentColor
        font.bold: true
        elide: Text.ElideRight
      }

      MesaIcon {
        Layout.alignment: Qt.AlignVCenter

        visible: root.navigable
        name: "arrow-right"
        size: Math.round(ConfigService.font.size * 1.2)
        color: root.contentColor
      }
    }

    MesaText {
      Layout.fillWidth: true

      text: root.sublabel
      color: root.active ? ConfigService.colors.background : ConfigService.colors.on_surface
      elide: Text.ElideRight
    }
  }
}

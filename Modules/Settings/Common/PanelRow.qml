import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

Rectangle {
  id: root

  property string label
  property color labelColor: ConfigService.colors.foreground
  property string sublabel
  property string value
  property color valueColor: ConfigService.colors.on_surface
  property Component leading: null
  property bool indented: false
  property bool chevron: false
  property bool interactive: false
  property bool selected: false
  property bool wideTrailing: false

  default property alias trailing: trailingRow.data

  readonly property int leadingSize: Math.round(ConfigService.font.size * 0.5)

  signal clicked

  Layout.fillWidth: true

  implicitHeight: content.implicitHeight + ConfigService.spacing
  color: root.selected ? ConfigService.colors.surface : "transparent"

  HoverHandler {
    enabled: root.interactive
    cursorShape: Qt.PointingHandCursor
  }

  TapHandler {
    enabled: root.interactive

    onTapped: root.clicked()
  }

  RowLayout {
    id: content

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: ConfigService.spacing
    anchors.rightMargin: ConfigService.spacing

    spacing: ConfigService.spacing

    Item {
      Layout.alignment: Qt.AlignVCenter

      visible: root.leading !== null || root.indented
      implicitWidth: root.leadingSize
      implicitHeight: root.leadingSize

      Loader {
        anchors.centerIn: parent

        active: root.leading !== null
        sourceComponent: root.leading
      }
    }

    ColumnLayout {
      Layout.fillWidth: true

      spacing: 0

      MesaText {
        Layout.fillWidth: true

        visible: root.label !== ""
        text: root.label
        color: root.labelColor
        elide: Text.ElideRight
      }

      MesaText {
        Layout.fillWidth: true

        visible: root.sublabel !== ""
        text: root.sublabel
        color: ConfigService.colors.on_surface
        elide: Text.ElideRight
      }
    }

    MesaText {
      Layout.alignment: Qt.AlignVCenter

      visible: root.value !== ""
      text: root.value
      color: root.valueColor
    }

    RowLayout {
      id: trailingRow

      Layout.fillWidth: root.wideTrailing
      Layout.alignment: Qt.AlignVCenter

      spacing: Math.round(ConfigService.spacing / 2)
    }

    MesaIcon {
      Layout.alignment: Qt.AlignVCenter

      visible: root.chevron
      name: "arrow-right"
      size: Math.round(ConfigService.font.size * 1.2)
      color: ConfigService.colors.on_surface
    }
  }
}

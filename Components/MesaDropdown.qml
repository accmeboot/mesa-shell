import QtQuick
import QtQuick.Layouts

import qs.Services

ColumnLayout {
  id: root

  property var options: []
  property var current: null
  property string placeholder: "None"
  property bool expanded: false

  readonly property var currentOption: root.options.find(option => option.value === root.current) ?? null
  readonly property int iconSize: Math.round(ConfigService.font.size * 1.5)
  readonly property int caretSize: Math.round(ConfigService.font.size * 1.2)
  // MesaButton centres its icon in a box padded by ConfigService.spacing, leaving
  // half of it either side; match that so icons line up down the column.
  readonly property int contentMargin: Math.round(ConfigService.spacing / 2)

  signal selected(var value)

  Layout.fillWidth: true

  spacing: 0

  Rectangle {
    Layout.fillWidth: true

    implicitHeight: field.implicitHeight + ConfigService.spacing
    color: ConfigService.colors.surface

    border.color: ConfigService.colors.on_surface
    border.width: ConfigService.border

    HoverHandler {
      cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
      onTapped: root.expanded = !root.expanded
    }

    RowLayout {
      id: field

      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: root.contentMargin
      anchors.rightMargin: root.contentMargin

      spacing: Math.round(ConfigService.spacing / 2)

      MesaIcon {
        Layout.alignment: Qt.AlignVCenter

        visible: (root.currentOption?.icon ?? "") !== ""
        name: root.currentOption?.icon ?? ""
        size: root.iconSize
        color: ConfigService.colors.foreground
      }

      MesaText {
        Layout.fillWidth: true

        text: root.currentOption?.text ?? root.placeholder
        color: root.currentOption ? ConfigService.colors.foreground : ConfigService.colors.on_surface
        elide: Text.ElideRight
      }

      MesaIcon {
        Layout.alignment: Qt.AlignVCenter

        name: "arrow-right"
        size: root.caretSize
        color: ConfigService.colors.foreground
        rotation: root.expanded ? -90 : 90
      }
    }
  }

  Rectangle {
    Layout.fillWidth: true
    Layout.topMargin: -ConfigService.border

    visible: root.expanded
    implicitHeight: list.implicitHeight + border.width * 2
    color: ConfigService.colors.background

    border.color: ConfigService.colors.on_surface
    border.width: ConfigService.border

    ColumnLayout {
      id: list

      anchors.fill: parent
      anchors.margins: parent.border.width

      spacing: 0

      Repeater {
        model: root.options

        Rectangle {
          id: option

          required property var modelData

          readonly property bool active: option.modelData.value === root.current

          Layout.fillWidth: true

          implicitHeight: entry.implicitHeight + ConfigService.spacing
          color: {
            const colors = ConfigService.colors;

            if (hover.hovered) return colors.highlight;

            return option.active ? colors.surface : colors.background;
          }

          HoverHandler {
            id: hover

            cursorShape: Qt.PointingHandCursor
          }

          TapHandler {
            onTapped: {
              root.expanded = false;
              root.selected(option.modelData.value);
            }
          }

          RowLayout {
            id: entry

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: root.contentMargin - ConfigService.border
            anchors.rightMargin: root.contentMargin - ConfigService.border

            spacing: Math.round(ConfigService.spacing / 2)

            MesaIcon {
              Layout.alignment: Qt.AlignVCenter

              visible: (option.modelData.icon ?? "") !== ""
              name: option.modelData.icon ?? ""
              size: root.iconSize
              color: hover.hovered ? ConfigService.colors.background : ConfigService.colors.foreground
            }

            MesaText {
              Layout.fillWidth: true

              text: option.modelData.text
              color: hover.hovered ? ConfigService.colors.background : ConfigService.colors.foreground
              elide: Text.ElideRight
            }
          }
        }
      }
    }
  }
}

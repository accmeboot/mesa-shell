import QtQuick
import QtQuick.Layouts

import qs.Services

Rectangle {
  id: root

  property var options: []
  property var current: null
  property string placeholder: "None"
  property bool expanded: false

  readonly property var currentOption: root.options.find(option => option.value === root.current) ?? null
  readonly property int iconSize: Math.round(ConfigService.font.size * 1.5)
  readonly property int caretSize: Math.round(ConfigService.font.size * 1.2)
  readonly property int contentMargin: ConfigService.spacing

  signal toggled()

  implicitHeight: root.iconSize + ConfigService.spacing
  color: ThemeService.colors.surface

  border.color: ThemeService.colors.on_surface
  border.width: ConfigService.border

  MouseArea {
    anchors.fill: parent

    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: root.toggled()
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
      color: ThemeService.colors.foreground
    }

    MesaText {
      Layout.fillWidth: true

      text: root.currentOption?.text ?? root.placeholder
      color: root.currentOption ? ThemeService.colors.foreground : ThemeService.colors.on_surface
      elide: Text.ElideRight
    }

    MesaIcon {
      Layout.alignment: Qt.AlignVCenter

      name: "pan-end"
      size: root.caretSize
      color: ThemeService.colors.foreground
      rotation: root.expanded ? -90 : 90
    }
  }
}

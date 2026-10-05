import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.Services
import qs.Components

RowLayout {
  id: root

  required property var screen

  spacing: 0

  Repeater {
    model: CompositorService.workspaces(root.screen.name)

    MesaButton {
      id: workspace

      required property var modelData

      Layout.fillHeight: true

      visible: modelData.monitor === root.screen.name

      text: workspace.modelData.name
      labelVisible: !workspace.modelData.focused

      Rectangle {
        id: focusSquare

        visible: workspace.modelData.focused

        x: Math.floor((parent.width - width) / 2)
        y: Math.floor((parent.height - height) / 2)
        width: Math.round(ConfigService.font.size) | 1
        height: width

        color: ThemeService.colors.highlight
      }

      Rectangle {
        visible: workspace.modelData.urgent

        readonly property int overlap: Math.round(width / 2)

        anchors.right: focusSquare.left
        anchors.bottom: focusSquare.top
        anchors.rightMargin: -overlap
        anchors.bottomMargin: -overlap

        width: Math.round(ConfigService.font.size / 2)
        height: width

        color: ThemeService.colors.critical
      }

      onClicked: workspace.modelData.activate()
    }
  }
}

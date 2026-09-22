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
    model: SwayService.getWorkspacesForMonitor(root.screen.name)

    MesaButton {
      id: workspace

      required property var modelData

      visible: modelData.monitor === root.screen.name

      text: modelData.name

      Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: ConfigService.border * 2
        visible: workspace.modelData.focused || workspace.modelData.urgent
        color: workspace.modelData.focused ? ThemeService.colors.highlight : ThemeService.colors.critical
      }

      onClicked: workspace.modelData.activate()
    }
  }
}

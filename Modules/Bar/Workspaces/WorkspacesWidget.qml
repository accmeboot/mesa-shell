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

      Layout.fillHeight: true

      visible: modelData.monitor === root.screen.name

      text: modelData.name
      underlined: workspace.modelData.focused || workspace.modelData.urgent
      underlineColor: workspace.modelData.focused ? ThemeService.colors.highlight : ThemeService.colors.critical

      onClicked: workspace.modelData.activate()
    }
  }
}

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

      horizontalPadding: ConfigService.spacing * 2

      text: modelData.name
      color: {
        if (modelData.focused) {
          return ThemeService.colors.highlight
        }

        if (modelData.urgent) {
          return ThemeService.colors.critical
        }

        return ThemeService.colors.surface
      }

      contentColor: modelData.focused ? ThemeService.colors.background : ThemeService.colors.foreground

      onClicked: workspace.modelData.activate()
    }
  }
}

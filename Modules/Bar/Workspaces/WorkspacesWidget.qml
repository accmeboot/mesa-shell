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
      accent: {
        if (workspace.modelData.focused) return ThemeService.colors.highlight;
        if (workspace.modelData.urgent) return ThemeService.colors.critical;

        return "transparent";
      }

      onClicked: workspace.modelData.activate()
    }
  }
}

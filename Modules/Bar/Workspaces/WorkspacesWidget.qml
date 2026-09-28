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

      text: modelData.name
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      accent: {
        if (workspace.modelData.focused) return ThemeService.colors.highlight;
        if (workspace.modelData.urgent) return ThemeService.colors.critical;

        return "transparent";
      }

      Rectangle {
        visible: workspace.modelData.occupied ?? false

        x: Math.round(ConfigService.spaceSm / 2)
        y: Math.round(ConfigService.spaceSm / 2)
        width: Math.round(ConfigService.font.size / 2)
        height: width

        color: workspace.modelData.holdsFocus ? workspace.effectiveContentColor : "transparent"
        border.color: workspace.effectiveContentColor
        border.width: 1
      }

      onClicked: mouse => {
        if (mouse.button === Qt.RightButton) workspace.modelData.toggle?.();
        else workspace.modelData.activate();
      }
    }
  }
}

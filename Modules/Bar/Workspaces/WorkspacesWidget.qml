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
      acceptedButtons: Qt.LeftButton | Qt.RightButton

      Rectangle {
        readonly property int knobInset: Math.max(ConfigService.border * 2, Math.round(ConfigService.iconSizeSmall / 6))

        visible: workspace.modelData.focused
        anchors.centerIn: parent
        width: ConfigService.iconSizeSmall - knobInset * 2
        height: width

        color: workspace.effectiveContentColor
      }

      Rectangle {
        visible: (workspace.modelData.occupied ?? false) || workspace.modelData.urgent

        x: Math.round(ConfigService.spaceSm / 2)
        y: Math.round(ConfigService.spaceSm / 2)
        width: Math.max(4, Math.round(ConfigService.font.size / 3))
        height: width
        radius: width / 2

        color: workspace.modelData.urgent ? ThemeService.colors.critical : workspace.effectiveContentColor
      }

      onClicked: mouse => {
        if (mouse.button === Qt.RightButton) workspace.modelData.toggle?.();
        else workspace.modelData.activate();
      }
    }
  }
}

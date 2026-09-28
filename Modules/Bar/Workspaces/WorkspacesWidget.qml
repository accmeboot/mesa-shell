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


        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: ConfigService.border

        implicitWidth: workspace.label.implicitWidth
        implicitHeight: ConfigService.border

        color: workspace.modelData.urgent ? ThemeService.colors.critical : workspace.effectiveContentColor
      }

      onClicked: mouse => {
        if (mouse.button === Qt.RightButton) workspace.modelData.toggle?.();
        else workspace.modelData.activate();
      }
    }
  }
}

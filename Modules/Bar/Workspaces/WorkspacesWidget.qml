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
        visible: workspace.modelData.focused

        anchors.centerIn: parent
        width: ConfigService.font.size
        height: width

        color: workspace.effectiveContentColor
      }

      Rectangle {
        visible: (workspace.modelData.occupied ?? false) || workspace.modelData.urgent

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: ConfigService.border

        implicitWidth: ConfigService.font.size
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

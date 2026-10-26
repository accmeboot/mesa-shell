import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import qs.Services
import qs.Components

Rectangle {
  id: root

  required property var screen

  readonly property bool windowsOpen: PanelService.current === "windows" && PanelService.screen === root.screen.name

  implicitWidth: row.implicitWidth
  implicitHeight: row.implicitHeight
  color: root.windowsOpen ? ThemeService.colors.surface : "transparent"

  TapHandler {
    acceptedButtons: Qt.RightButton
    onTapped: PanelService.toggle("windows", root.screen.name)
  }

  MesaPopup {
    open: root.windowsOpen
    screen: root.screen
    anchorItem: root
    exclude: root
    namespace: "mesa-windows"
    keyboardFocus: WlrKeyboardFocus.Exclusive

    content: WindowsPanel {}

    onDismissed: PanelService.close("windows")
  }

  RowLayout {
    id: row

    anchors.fill: parent

    spacing: ConfigService.space

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
}

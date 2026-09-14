import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.Services
import qs.Components

Scope {
  id: root

  readonly property var screen: Quickshell.screens.find(screen => screen.name === SettingsService.screen) ?? Quickshell.screens[0] ?? null

  MesaCatcher {
    active: SettingsService.isOpen
    namespace: "mesa-settings-catcher"

    onDismissed: SettingsService.close()
  }

  LazyLoader {
    activeAsync: SettingsService.isOpen

    PanelWindow {
      id: window

      screen: root.screen
      color: "transparent"
      exclusiveZone: 0

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
      WlrLayershell.namespace: "mesa-settings"

      implicitWidth: Math.round(ConfigService.font.size * 34)
      implicitHeight: Math.min(panel.implicitHeight, window.screen ? window.screen.height * 0.8 : panel.implicitHeight)

      anchors {
        top: true
        left: true
      }

      Panel {
        id: panel

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: window.implicitHeight
      }
    }
  }
}

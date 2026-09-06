import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.Services

Scope {
  id: root

  readonly property var focusedScreen: {
    const screens = Quickshell.screens;

    return screens.find(screen => screen.name === SwayService.focusedOutput) ?? screens[0] ?? null;
  }

  LazyLoader {
    activeAsync: SettingsService.isOpen

    Scope {
      Variants {
        model: Quickshell.screens

        PanelWindow {
          required property var modelData

          screen: modelData
          color: "transparent"
          exclusionMode: ExclusionMode.Ignore

          WlrLayershell.layer: WlrLayer.Top
          WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
          WlrLayershell.namespace: "mesa-settings-catcher"

          anchors {
            top: true
            bottom: true
            left: true
            right: true
          }

          MouseArea {
            anchors.fill: parent

            onClicked: SettingsService.close()
          }
        }
      }

      PanelWindow {
        id: window

        screen: root.focusedScreen
        color: "transparent"
        exclusiveZone: 0

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "mesa-settings"

        implicitWidth: Math.round(ConfigService.font.size * 34)
        implicitHeight: Math.min(panel.implicitHeight, window.screen ? window.screen.height * 0.8 : panel.implicitHeight)

        anchors {
          top: true
          right: true
        }

        Panel {
          id: panel

          anchors.fill: parent
        }
      }
    }
  }
}

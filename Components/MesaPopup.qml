import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.Services

Scope {
  id: root

  property bool open: false
  property var screen: null
  property Item exclude: null
  property string namespace: "mesa-popup"
  property int keyboardFocus: WlrKeyboardFocus.None
  property int width: Math.round(ConfigService.font.size * 34)

  property Component content: null

  signal dismissed()

  MesaCatcher {
    active: root.open
    layer: WlrLayer.Overlay
    namespace: `${root.namespace}-catcher`
    exclude: root.exclude
    excludeScreen: root.screen

    onDismissed: root.dismissed()
  }

  LazyLoader {
    activeAsync: root.open

    PanelWindow {
      id: window

      screen: root.screen
      color: "transparent"
      exclusiveZone: 0

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: root.keyboardFocus
      WlrLayershell.namespace: root.namespace

      implicitWidth: root.width
      implicitHeight: background.implicitHeight

      anchors {
        top: true
        right: true
      }

      Rectangle {
        id: background

        anchors.fill: parent

        implicitHeight: body.implicitHeight + ConfigService.spacing * 2 + border.width * 2
        color: ThemeService.colors.background

        border.color: ThemeService.colors.on_surface
        border.width: ConfigService.border

        Loader {
          id: body

          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.leftMargin: background.border.width
          anchors.rightMargin: background.border.width
          anchors.topMargin: background.border.width + ConfigService.spacing

          sourceComponent: root.content
        }
      }
    }
  }
}

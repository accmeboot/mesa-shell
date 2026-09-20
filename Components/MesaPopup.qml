import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Window

import qs.Services

Scope {
  id: root

  property bool open: false
  property var screen: null
  property Item exclude: null
  property string namespace: "mesa-popup"
  property int keyboardFocus: WlrKeyboardFocus.None
  property int width: Math.round(ConfigService.font.size * 25.4)

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

      FocusScope {
        id: scope

        property bool navigable: true

        function focusFirst(): void {
          scope.forceActiveFocus();
          scope.nextItemInFocusChain(true).forceActiveFocus(Qt.TabFocusReason);
        }

        function focusStep(forward: bool): void {
          const current = scope.Window.activeFocusItem ?? scope;

          current.nextItemInFocusChain(forward).forceActiveFocus(Qt.TabFocusReason);
        }

        anchors.fill: parent

        focus: true

        Keys.onEscapePressed: root.dismissed()
        Keys.onDownPressed: scope.focusStep(true)
        Keys.onUpPressed: scope.focusStep(false)

        Keys.onPressed: event => {
          switch (event.key) {
          case Qt.Key_J:
            scope.focusStep(true);
            break;
          case Qt.Key_K:
            scope.focusStep(false);
            break;
          default:
            return;
          }

          event.accepted = true;
        }

        Component.onCompleted: Qt.callLater(scope.focusFirst)

        Rectangle {
          id: background

          anchors.fill: parent

          implicitHeight: body.implicitHeight + ConfigService.padding * 2 + border.width * 2
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
            anchors.topMargin: background.border.width + ConfigService.padding

            sourceComponent: root.content
          }
        }
      }
    }
  }
}

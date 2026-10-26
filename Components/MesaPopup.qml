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
  property Item anchorItem: null
  property string namespace: "mesa-popup"
  property int keyboardFocus: WlrKeyboardFocus.None
  readonly property int minimumWidth: Math.min(ConfigService.panelMinWidth, root.maximumWidth)
  readonly property int maximumWidth: Math.min(ConfigService.panelMaxWidth, root.screen?.width || Infinity)

  property string direction: "auto"

  readonly property real anchorLeft: PanelService.screenX(root.anchorItem)
  readonly property real anchorRight: root.anchorLeft + (root.anchorItem?.width ?? 0)

  property Component content: null

  signal dismissed()

  onOpenChanged: if (!root.open) MenuService.close()

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

      readonly property real desiredLeft: root.anchorLeft - ConfigService.border
      readonly property bool opensRight: {
        if (root.direction !== "auto") return root.direction === "right";

        return window.desiredLeft + background.implicitWidth <= (root.screen?.width ?? 0);
      }

      implicitWidth: background.implicitWidth
      implicitHeight: root.screen?.height ?? background.implicitHeight

      anchors {
        top: !ConfigService.bottom
        bottom: ConfigService.bottom
        left: window.opensRight
        right: !window.opensRight
      }

      margins.top: -ConfigService.border
      margins.bottom: -ConfigService.border

      mask: Region { item: background.background }

      margins.left: {
        const available = root.screen?.width ?? 0;

        if (!window.opensRight || !root.anchorItem || available === 0) return 0;

        const furthest = Math.max(0, available - background.implicitWidth);

        return Math.round(Math.max(0, Math.min(window.desiredLeft, furthest)));
      }

      margins.right: {
        const available = root.screen?.width ?? 0;

        if (window.opensRight || !root.anchorItem || available === 0) return 0;

        const desired = available - root.anchorRight - ConfigService.border;
        const furthest = Math.max(0, available - background.implicitWidth);

        return Math.round(Math.max(0, Math.min(desired, furthest)));
      }

      FocusScope {
        id: scope

        function focusFirst(): void {
          scope.forceActiveFocus();
          scope.nextItemInFocusChain(true).forceActiveFocus(Qt.TabFocusReason);
        }

        function focusStep(forward: bool): void {
          const current = scope.Window.activeFocusItem ?? scope;

          current.nextItemInFocusChain(forward).forceActiveFocus(Qt.TabFocusReason);
        }

        function openMenu(): void {
          if (MenuService.isOpen) return;

          const item = scope.Window.activeFocusItem;

          if (item && item.openMenu) item.openMenu();
        }

        function horizontal(event, delta: int): void {
          if (event.modifiers & Qt.ShiftModifier) {
            if (MenuService.isOpen) MenuService.current.adjust(delta);
            return;
          }

          if (delta > 0) scope.openMenu();
          else MenuService.close();
        }

        anchors.fill: parent

        focus: true

        Keys.onEscapePressed: root.dismissed()

        Keys.onDownPressed: MenuService.isOpen ? MenuService.current.step(1) : scope.focusStep(true)
        Keys.onUpPressed: MenuService.isOpen ? MenuService.current.step(-1) : scope.focusStep(false)
        Keys.onRightPressed: event => scope.horizontal(event, 1)
        Keys.onLeftPressed: event => scope.horizontal(event, -1)
        Keys.onReturnPressed: if (MenuService.isOpen) MenuService.current.activate()
        Keys.onEnterPressed: if (MenuService.isOpen) MenuService.current.activate()

        Keys.onPressed: event => {
          const menu = MenuService.current;

          switch (event.key) {
          case Qt.Key_J:
            menu ? menu.step(1) : scope.focusStep(true);
            break;
          case Qt.Key_K:
            menu ? menu.step(-1) : scope.focusStep(false);
            break;
          case Qt.Key_L:
            scope.horizontal(event, 1);
            break;
          case Qt.Key_H:
            scope.horizontal(event, -1);
            break;
          default:
            return;
          }

          event.accepted = true;
        }

        Component.onCompleted: Qt.callLater(scope.focusFirst)

        MesaSurface {
          id: background

          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: ConfigService.bottom ? undefined : parent.top
          anchors.bottom: ConfigService.bottom ? parent.bottom : undefined
          minimumWidth: root.minimumWidth
          maximumWidth: root.maximumWidth

          contentItem: Loader {
            sourceComponent: root.content
          }
        }
      }
    }
  }
}

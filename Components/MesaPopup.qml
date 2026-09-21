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
  readonly property int minimumWidth: Math.round(ConfigService.font.size * 25)
  readonly property int maximumWidth: Math.max(root.minimumWidth, Math.round((root.screen?.width ?? 0) / 3))

  readonly property real anchorRight: {
    const item = root.anchorItem;

    if (!item) return 0;

    let edge = item.width;

    for (let node = item; node; node = node.parent) {
      edge += node.x;
    }

    return edge;
  }

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

      implicitWidth: Math.max(root.minimumWidth, Math.min(root.maximumWidth, background.implicitWidth))
      implicitHeight: background.implicitHeight

      anchors {
        top: true
        right: true
      }

      margins.right: {
        const available = root.screen?.width ?? 0;

        if (!root.anchorItem || available === 0) return 0;

        const desired = available - root.anchorRight;
        const furthest = Math.max(0, available - root.maximumWidth);

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

        Rectangle {
          id: background

          anchors.fill: parent

          implicitWidth: body.implicitWidth + border.width * 2
          implicitHeight: body.implicitHeight + border.width * 2
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
            anchors.topMargin: background.border.width

            sourceComponent: root.content
          }
        }
      }
    }
  }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import qs.Services
import qs.Components

RowLayout {
  id: root

  required property var screen

  readonly property bool isOpen: DmenuService.isOpen && DmenuService.screen === root.screen.name
  readonly property bool choosing: DmenuService.mode === "choose"
  readonly property bool hasArguments: !choosing && /\s/.test(searchField.text.trim())

  property int currentIndex: 0
  property real listWidth: 0

  property var filteredItems: {
    if (hasArguments) {
      return [];
    }

    const source = choosing ? DmenuService.items : DmenuService.applications;
    const query = searchField.text.trim().toLowerCase();
    if (query === "") {
      return source;
    }
    return source.filter(item => item.toLowerCase().includes(query));
  }

  readonly property var options: root.filteredItems.map(item => ({
    text: item,
    value: item
  }))

  readonly property real anchorLeft: root.x + menuRow.x + searchField.x

  function selectNext(): void {
    if (root.currentIndex < 0) {
      root.currentIndex = 0;
    } else {
      root.currentIndex = Math.min(root.filteredItems.length - 1, root.currentIndex + 1);
    }
  }

  function selectPrevious(): void {
    if (root.currentIndex < 0) {
      root.currentIndex = 0;
    } else {
      root.currentIndex = Math.max(0, root.currentIndex - 1);
    }
  }

  function submit(): void {
    const hasSelection = root.currentIndex >= 0 && root.currentIndex < filteredItems.length;

    if (choosing) {
      if (hasSelection) {
        DmenuService.resolve(filteredItems[root.currentIndex]);
      }
      return;
    }

    if (hasSelection) {
      DmenuService.execute(filteredItems[root.currentIndex]);
      return;
    }

    const command = searchField.text.trim();
    if (command !== "") {
      DmenuService.execute(command);
    }
  }

  spacing: 0

  MesaCatcher {
    active: root.isOpen
    layer: WlrLayer.Overlay
    namespace: "mesa-dmenu-catcher"
    excludeScreen: root.screen

    onDismissed: DmenuService.close()
  }

  MesaButton {
    Layout.fillHeight: true
    icon: "cm_runterm"
    onClicked: root.isOpen ? DmenuService.close() : DmenuService.open(root.screen.name)
  }

  RowLayout {
    id: menuRow

    Layout.fillWidth: true

    visible: root.isOpen
    spacing: 0

    onVisibleChanged: {
      if (visible) {
        searchField.forceActiveFocus();
        return;
      }

      searchField.text = "";
      root.currentIndex = 0;
    }

    MesaInput {
      id: searchField

      Layout.fillHeight: true
      Layout.fillWidth: true
      Layout.minimumWidth: Math.round(ConfigService.font.size * 6)
      Layout.preferredWidth: root.listWidth
      Layout.maximumWidth: root.listWidth

      onTextChanged: {
        root.currentIndex = 0;
      }

      Keys.onEscapePressed: DmenuService.close()
      Keys.onReturnPressed: root.submit()
      Keys.onEnterPressed: root.submit()
      Keys.onRightPressed: root.selectNext()
      Keys.onDownPressed: root.selectNext()
      Keys.onTabPressed: root.selectNext()
      Keys.onLeftPressed: root.selectPrevious()
      Keys.onUpPressed: root.selectPrevious()
      Keys.onBacktabPressed: root.selectPrevious()

      Keys.onPressed: event => {
        if ((event.modifiers & Qt.ControlModifier) === 0) return;

        switch (event.key) {
        case Qt.Key_J:
        case Qt.Key_L:
          root.selectNext();
          break;
        case Qt.Key_K:
        case Qt.Key_H:
          root.selectPrevious();
          break;
        default:
          return;
        }

        event.accepted = true;
      }
    }
  }

  LazyLoader {
    activeAsync: root.isOpen

    PanelWindow {
      id: window

      screen: root.screen
      color: "transparent"
      exclusiveZone: 0

      visible: root.filteredItems.length > 0

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      WlrLayershell.namespace: "mesa-dmenu"

      readonly property real limit: (root.screen?.width ?? 0) - root.anchorLeft

      implicitWidth: searchField.width
      implicitHeight: list.implicitHeight

      Component.onCompleted: {
        root.listWidth = Math.min(list.implicitWidth, window.limit);
      }

      anchors {
        top: true
        left: true
      }

      margins.left: root.anchorLeft

      MesaSelectList {
        id: list

        anchors.fill: parent

        options: root.options
        currentIndex: root.currentIndex
        maximumRows: 20

        onStepped: delta => delta > 0 ? root.selectNext() : root.selectPrevious()

        onSelected: value => {
          root.currentIndex = root.filteredItems.indexOf(value);
          root.submit();
        }
      }
    }
  }
}

import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import qs.Services

RowLayout {
  id: root

  required property var screen
  required property string panel

  property alias icon: button.icon
  property alias iconColor: button.contentColor
  property alias accent: button.accent
  property Component content: null

  readonly property bool isOpen: root.visible && PanelService.current === root.panel && PanelService.screen === root.screen.name

  spacing: 0

  MesaButton {
    id: button

    Layout.fillHeight: true

    open: root.isOpen

    onClicked: PanelService.toggle(root.panel, root.screen.name)
  }

  MesaPopup {
    open: root.isOpen
    screen: root.screen
    anchorItem: root
    exclude: root
    namespace: `mesa-${root.panel}`
    keyboardFocus: WlrKeyboardFocus.Exclusive

    content: root.content

    onDismissed: PanelService.close(root.panel)
  }
}

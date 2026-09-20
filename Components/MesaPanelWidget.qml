import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import qs.Services

RowLayout {
  id: root

  required property var screen
  required property int popupWidth
  required property string panel

  property string icon
  property color iconColor: ThemeService.colors.foreground
  property Component content: null

  readonly property bool isOpen: root.visible && PanelService.current === root.panel && PanelService.screen === root.screen.name

  spacing: 0

  MesaButton {
    Layout.fillHeight: true

    icon: root.icon
    contentColor: root.iconColor

    onClicked: PanelService.toggle(root.panel, root.screen.name)
  }

  MesaPopup {
    open: root.isOpen
    screen: root.screen
    width: root.popupWidth
    exclude: root
    namespace: `mesa-${root.panel}`
    keyboardFocus: WlrKeyboardFocus.Exclusive

    content: root.content

    onDismissed: PanelService.close(root.panel)
  }
}

import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import qs.Services

RowLayout {
  id: root

  required property var screen
  required property string panel

  property string icon
  property color iconColor: ThemeService.colors.foreground
  property var icons: [{ icon: root.icon, color: root.iconColor }]
  property Component content: null

  readonly property bool isOpen: root.visible && PanelService.current === root.panel && PanelService.screen === root.screen.name

  spacing: 0

  Repeater {
    model: root.icons

    MesaButton {
      required property var modelData

      Layout.fillHeight: true

      icon: modelData.icon
      contentColor: modelData.color
      underlined: root.isOpen

      onClicked: PanelService.toggle(root.panel, root.screen.name)
    }
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

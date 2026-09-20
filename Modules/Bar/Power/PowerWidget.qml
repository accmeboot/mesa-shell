import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

RowLayout {
  id: root

  required property var screen
  required property int popupWidth

  readonly property bool isOpen: PanelService.current === "power" && PanelService.screen === root.screen.name

  spacing: 0

  MesaButton {
    id: button

    Layout.fillHeight: true

    icon: "system-shutdown"
    contentColor: ThemeService.colors.critical

    onClicked: PanelService.toggle("power", root.screen.name)
  }

  MesaPopup {
    open: root.isOpen
    screen: root.screen
    width: root.popupWidth
    exclude: root
    namespace: "mesa-power"
    keyboardFocus: WlrKeyboardFocus.Exclusive

    content: PowerPanel {
      onRequestClose: PanelService.close("power")
    }

    onDismissed: PanelService.close("power")
  }
}

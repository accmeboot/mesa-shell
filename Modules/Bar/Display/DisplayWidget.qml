import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

RowLayout {
  id: root

  required property var screen
  required property int popupWidth

  readonly property bool isOpen: PanelService.current === "display" && PanelService.screen === root.screen.name

  spacing: 0

  MesaButton {
    id: button

    Layout.fillHeight: true

    icon: "video-display"

    onClicked: PanelService.toggle("display", root.screen.name)
  }

  MesaPopup {
    open: root.isOpen
    screen: root.screen
    width: root.popupWidth
    exclude: root
    namespace: "mesa-display"
    keyboardFocus: WlrKeyboardFocus.Exclusive

    content: DisplayPanel {}

    onDismissed: PanelService.close("display")
  }
}

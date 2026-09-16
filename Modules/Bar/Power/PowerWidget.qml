import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

RowLayout {
  id: root

  required property var screen

  property bool isOpen: false

  spacing: 0

  MesaButton {
    id: button

    Layout.fillHeight: true

    icon: "system-shutdown"
    contentColor: ThemeService.colors.critical

    onClicked: root.isOpen = !root.isOpen
    horizontalPadding: ConfigService.spacing * 2
  }

  MesaPopup {
    open: root.isOpen
    screen: root.screen
    exclude: root
    namespace: "mesa-power"
    anchorRight: root.x + button.x + button.width

    content: PowerPanel {
      onRequestClose: root.isOpen = false
    }

    onDismissed: root.isOpen = false
  }
}

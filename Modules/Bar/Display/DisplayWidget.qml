import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

RowLayout {
  id: root

  required property var screen
  required property int popupWidth

  property bool isOpen: false

  spacing: 0

  MesaButton {
    id: button

    Layout.fillHeight: true

    icon: "video-display"

    onClicked: root.isOpen = !root.isOpen
  }

  MesaPopup {
    open: root.isOpen
    screen: root.screen
    width: root.popupWidth
    exclude: root
    namespace: "mesa-display"

    content: DisplayPanel {}

    onDismissed: root.isOpen = false
  }
}

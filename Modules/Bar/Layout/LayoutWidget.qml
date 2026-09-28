import QtQuick

import qs.Services
import qs.Components

MesaButton {
  id: root

  required property var screen

  readonly property string symbol: CompositorService.layout(root.screen.name)

  visible: root.symbol !== ""

  text: root.symbol.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")

  onClicked: CompositorService.cycleLayout(root.screen.name)
}

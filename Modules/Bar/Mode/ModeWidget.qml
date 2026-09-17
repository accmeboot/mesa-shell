import QtQuick
import Quickshell

import qs.Services
import qs.Components

Rectangle {
  visible: SwayService.mode === 'resize'

  color: "transparent"

  implicitWidth: label.implicitWidth + ConfigService.gap * 2
  implicitHeight: label.implicitHeight + ConfigService.gap

  MesaText {
    id: label
    anchors.centerIn: parent
    text: SwayService.mode
    color: ThemeService.colors.attention
  }
}

import QtQuick
import Quickshell

import qs.Services
import qs.Components

Rectangle {
  visible: SwayService.mode === 'resize'

  color: "transparent"

  implicitWidth: label.implicitWidth + ConfigService.spacing
  implicitHeight: label.implicitHeight + ConfigService.spacing

  MesaText {
    id: label
    anchors.centerIn: parent
    text: SwayService.mode
    color: ThemeService.colors.attention
  }
}

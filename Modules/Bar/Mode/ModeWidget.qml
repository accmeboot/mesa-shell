import QtQuick
import Quickshell

import qs.Services
import qs.Components

Rectangle {
  visible: SwayService.mode === 'resize'

  color: "transparent"

  implicitWidth: label.implicitWidth + ConfigService.spaceMd * 2
  implicitHeight: label.implicitHeight + ConfigService.spaceMd

  MesaText {
    id: label
    anchors.centerIn: parent
    text: SwayService.mode
    color: ThemeService.colors.attention
  }
}

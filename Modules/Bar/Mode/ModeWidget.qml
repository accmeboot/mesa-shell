import QtQuick
import Quickshell

import qs.Services
import qs.Components

Rectangle {
  visible: CompositorService.mode === 'resize'

  color: "transparent"

  implicitWidth: label.implicitWidth + ConfigService.spaceMd * 2
  implicitHeight: label.implicitHeight + ConfigService.spaceMd

  MesaText {
    id: label
    anchors.centerIn: parent
    text: CompositorService.mode
    color: ThemeService.colors.attention
  }
}

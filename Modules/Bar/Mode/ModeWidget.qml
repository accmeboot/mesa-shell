import QtQuick

import qs.Components
import qs.Services

Rectangle {
  visible: CompositorService.mode !== "" && CompositorService.mode !== "default"
  color: ThemeService.colors.attention

  implicitWidth: label.implicitWidth + ConfigService.spaceMd * 2
  implicitHeight: label.implicitHeight + ConfigService.spaceMd

  MesaText {
    id: label

    anchors.centerIn: parent

    text: CompositorService.mode
    color: ThemeService.colors.background
  }
}

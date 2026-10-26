import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

MesaRow {
  id: root

  interactive: true
  wideTrailing: true
  activeFocusOnTab: false

  onActiveFocusChanged: if (root.activeFocus) brightness.forceActiveFocus(Qt.MouseFocusReason)

  Component.onCompleted: BrightnessService.refresh()

  TextMetrics {
    id: brightnessMetrics

    font: percent.font
    text: "100%"
  }

  MesaIcon {
    Layout.alignment: Qt.AlignVCenter

    name: "brightnesssettings"
    size: ConfigService.iconSize
    color: root.foreground
  }

  MesaSlider {
    id: brightness

    Layout.alignment: Qt.AlignVCenter
    Layout.fillWidth: true

    hoverEnabled: false

    // 0% cuts the backlight entirely, which reads as a dead screen
    from: 0.01

    value: BrightnessService.percentage

    onMoved: BrightnessService.setPercentage(brightness.value)
  }

  MesaText {
    id: percent

    Layout.preferredWidth: Math.ceil(brightnessMetrics.advanceWidth)
    Layout.alignment: Qt.AlignVCenter

    text: `${Math.round(brightness.value * 100)}%`
    color: root.foreground
    horizontalAlignment: Text.AlignRight
  }
}

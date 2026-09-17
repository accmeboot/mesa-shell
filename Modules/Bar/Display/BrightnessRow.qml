import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

MesaRow {
  id: root

  wideTrailing: true

  Component.onCompleted: BrightnessService.refresh()

  TextMetrics {
    id: brightnessMetrics

    font: percent.font
    text: "100%"
  }

  MesaIcon {
    Layout.alignment: Qt.AlignVCenter
    Layout.rightMargin: ConfigService.gap - ConfigService.gapSmall

    name: "brightnesssettings"
    size: ConfigService.iconSize
  }

  MesaSlider {
    id: brightness

    Layout.alignment: Qt.AlignVCenter
    Layout.fillWidth: true

    // 0% cuts the backlight entirely, which reads as a dead screen
    from: 0.01

    value: BrightnessService.percentage

    onMoved: BrightnessService.setPercentage(brightness.value)
  }

  MesaText {
    id: percent

    Layout.preferredWidth: Math.ceil(brightnessMetrics.advanceWidth)
    Layout.leftMargin: ConfigService.gap - ConfigService.gapSmall
    Layout.alignment: Qt.AlignVCenter

    text: `${Math.round(brightness.value * 100)}%`
    horizontalAlignment: Text.AlignRight
  }
}

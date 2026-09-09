import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

RowLayout {
  id: root

  readonly property int iconSize: Math.round(ConfigService.font.size * 1.5)

  Layout.fillWidth: true
  Layout.leftMargin: ConfigService.spacing
  Layout.rightMargin: ConfigService.spacing

  spacing: Math.round(ConfigService.spacing / 2)

  Component.onCompleted: BrightnessService.refresh()

  TextMetrics {
    id: brightnessMetrics

    font: percent.font
    text: "100%"
  }

  // matches MesaButton's footprint so it lines up with the audio rows, but
  // stays a plain icon because there is nothing here to click
  Item {
    Layout.alignment: Qt.AlignVCenter

    implicitWidth: glyph.implicitWidth + ConfigService.spacing
    implicitHeight: glyph.implicitHeight + ConfigService.spacing

    MesaIcon {
      id: glyph

      anchors.centerIn: parent

      name: "brightness"
      size: root.iconSize
    }
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
    Layout.leftMargin: Math.round(ConfigService.spacing / 2)
    Layout.alignment: Qt.AlignVCenter

    text: `${Math.round(brightness.value * 100)}%`
    horizontalAlignment: Text.AlignRight
  }
}

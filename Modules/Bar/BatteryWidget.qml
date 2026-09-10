import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

import qs.Components
import qs.Services

Rectangle {
  id: root

  color: ThemeService.colors.background

  implicitWidth: batteryRow.implicitWidth + ConfigService.spacing
  implicitHeight: batteryRow.implicitHeight + ConfigService.spacing

  property UPowerDevice device: UPower.displayDevice
  property int percentage: device ? device.percentage * 100 : null

  visible: device.isLaptopBattery

  readonly property string icon: {
    switch (device.state) {
    case UPowerDeviceState.Charging:
      return "battery-full-charging"
    case UPowerDeviceState.PendingCharge:
      return "battery_plugged"
    case UPowerDeviceState.FullyCharged:
      return "battery-full"
    case UPowerDeviceState.Empty:
      return "battery-empty"
    }

    if (percentage >= 90) return "battery-full"
    if (percentage >= 65) return "battery-good"
    if (percentage >= 40) return "battery-medium"
    if (percentage >= 15) return "battery-low"

    return "battery-empty"
  }

  RowLayout {
    id: batteryRow
    anchors.centerIn: parent

    MesaIcon {
      name: root.icon
      size: Math.round(ConfigService.font.size * 1.5)
      color: ColorService.threshold(root.percentage, 50, 20)
    }

    MesaText {
      text: root.percentage + "%"
    }
  }
}

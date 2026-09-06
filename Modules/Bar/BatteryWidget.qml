import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

import qs.Components
import qs.Services

Rectangle {
  id: root

  color: ConfigService.colors.background

  implicitWidth: batteryRow.implicitWidth + ConfigService.spacing
  implicitHeight: batteryRow.implicitHeight + ConfigService.spacing

  property UPowerDevice device: UPower.displayDevice
  property int percentage: device ? device.percentage * 100 : null

  visible: device.isLaptopBattery

  readonly property string status: {
    switch (device.state) {
    case UPowerDeviceState.Charging:
      return "charging"
    case UPowerDeviceState.PendingCharge:
      return "plugged"
    case UPowerDeviceState.FullyCharged:
      return "full"
    case UPowerDeviceState.Empty:
      return "empty"
    case UPowerDeviceState.Discharging:
    case UPowerDeviceState.PendingDischarge:
      return "on battery"
    }

    return "unknown"
  }

  RowLayout {
    id: batteryRow
    anchors.centerIn: parent

    MesaText {
      text: "BAT"
      color: ColorService.threshold(root.percentage, 50, 20)
    }

    MesaText {
      text: root.percentage + "% (" + root.status + ")"
    }
  }
}

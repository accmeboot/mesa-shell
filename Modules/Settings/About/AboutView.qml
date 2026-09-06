import QtQuick.Layouts

import qs.Services

ColumnLayout {
  spacing: ConfigService.spacing

  SystemGroup {}

  BatteryGroup {}
}

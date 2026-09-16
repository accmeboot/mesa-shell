import QtQuick.Layouts

import qs.Services

ColumnLayout {
  spacing: ConfigService.spacing * 2

  BrightnessGroup {}

  OutputGroup {}

  MonitorGroup {}
}

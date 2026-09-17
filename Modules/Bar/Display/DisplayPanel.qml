import QtQuick.Layouts

import qs.Services

ColumnLayout {
  spacing: ConfigService.gapBig

  BrightnessGroup {}

  OutputGroup {}

  MonitorGroup {}
}

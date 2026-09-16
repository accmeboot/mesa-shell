import QtQuick.Layouts

import qs.Services

ColumnLayout {
  spacing: ConfigService.spacing * 2

  EthernetGroup {}

  WifiGroup {}
}

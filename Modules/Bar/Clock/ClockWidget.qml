import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Services

Rectangle {
  color: "transparent"

  implicitWidth: clockRow.implicitWidth + ConfigService.spaceMd * 2
  implicitHeight: clockRow.implicitHeight + ConfigService.spaceMd

  RowLayout {
    id: clockRow
    anchors.centerIn: parent

    MesaText {
      SystemClock {
        id: clock
        precision: SystemClock.Minutes
      }

      text: Qt.formatDateTime(clock.date, ConfigService.dateTimeFormat)
    }
  }
}

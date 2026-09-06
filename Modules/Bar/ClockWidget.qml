import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Services

Rectangle {
  color: ConfigService.colors.background

  implicitWidth: clockRow.implicitWidth + ConfigService.spacing
  implicitHeight: clockRow.implicitHeight + ConfigService.spacing

  RowLayout {
    id: clockRow
    anchors.centerIn: parent

    MesaText {
      SystemClock {
        id: clock
        precision: SystemClock.Minutes
      }

      text: Qt.formatDateTime(clock.date, "dddd HH:mm")
    }
  }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import qs.Components
import qs.Services

Rectangle {
  id: root

  color: ConfigService.colors.background

  implicitWidth: cpuRow.implicitWidth + ConfigService.spacing
  implicitHeight: cpuRow.implicitHeight + ConfigService.spacing

  property int usage: 0

  RowLayout {
    id: cpuRow
    anchors.centerIn: parent

    MesaText {
      text: "CPU"
      color: ColorService.threshold(root.usage, 20, 60)
    }

    MesaText {
      text: usage + "%"
    }
  }

  FileView {
    id: statFile

    property real previousTotal: 0
    property real previousIdle: 0

    path: "/proc/stat"

    onLoaded: {
      const times = text().split("\n")[0].split(/\s+/).slice(1).map(Number)

      const total = times.reduce((sum, time) => sum + time, 0)
      const idle = times[3] + times[4]

      const totalDiff = total - previousTotal
      const idleDiff = idle - previousIdle

      const hasBaseline = previousTotal > 0

      previousTotal = total
      previousIdle = idle

      if (hasBaseline && totalDiff > 0) root.usage = Math.round((1 - idleDiff / totalDiff) * 100)
    }

    Component.onCompleted: reload()
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: statFile.reload()
  }
}

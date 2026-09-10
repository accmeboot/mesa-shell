import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import qs.Components
import qs.Services

Rectangle {
  id: root

  color: ThemeService.colors.background

  implicitWidth: ramRow.implicitWidth + ConfigService.spacing
  implicitHeight: ramRow.implicitHeight + ConfigService.spacing

  property real used: 0
  property real total: 0

  readonly property real usage: total > 0 ? used / total * 100 : 0

  RowLayout {
    id: ramRow
    anchors.centerIn: parent

    MesaIcon {
      name: "media-memory"
      size: Math.round(ConfigService.font.size * 1.5)
      color: ColorService.threshold(root.usage, 50, 80)
    }

    MesaText {
      text: used.toFixed(1) + "G" + " / " + total.toFixed(0) + "G"
    }
  }

  FileView {
    id: meminfoFile

    path: "/proc/meminfo"

    onLoaded: {
      function field(name) {
        const match = text().match(new RegExp("^" + name + ":\\s+(\\d+)", "m"))
        return match ? Number(match[1]) / 1024 / 1024 : 0
      }

      const memTotal = field("MemTotal")
      const memAvailable = field("MemAvailable")

      root.total = memTotal
      root.used = memTotal - memAvailable
    }

    Component.onCompleted: reload()
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: meminfoFile.reload()
  }
}

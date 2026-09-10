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
      name: "memory"
      Layout.alignment: Qt.AlignTop
      Layout.topMargin: Math.round(label.baselineOffset + glyphs.tightBoundingRect.y + glyphs.tightBoundingRect.height / 2 - size / 2)
      size: {
        const base = Math.round(ConfigService.font.size * 1.5)
        return base + Math.abs(glyphs.tightBoundingRect.height - base) % 2
      }
      color: ColorService.threshold(root.usage, 50, 80)
    }

    MesaText {
      id: label
      text: used.toFixed(1) + "G" + " / " + total.toFixed(0) + "G"
    }

    TextMetrics {
      id: glyphs
      font: label.font
      text: "0123456789"
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

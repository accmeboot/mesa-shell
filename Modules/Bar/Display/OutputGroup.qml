import Quickshell.I3

import qs.Services
import qs.Components

MesaSection {
  id: root

  readonly property I3Monitor monitor: I3.focusedMonitor
  readonly property var info: root.monitor?.lastIpcObject ?? null
  readonly property var mode: root.info?.current_mode ?? null

  title: "Output"

  MesaRow {
    label: "Name"
    value: root.monitor?.name ?? ""
    fallback: "Unknown"
  }

  MesaRow {
    label: "Resolution"
    value: root.mode ? `${root.mode.width}x${root.mode.height}` : ""
    fallback: "Unknown"
  }

  MesaRow {
    label: "Refresh"
    // sway reports the refresh rate in mHz
    value: root.mode?.refresh > 0 ? `${(root.mode.refresh / 1000).toFixed(2)} Hz` : ""
    fallback: "Unknown"
  }

  MesaRow {
    label: "Scale"
    value: root.monitor ? root.monitor.scale.toFixed(2) : ""
    fallback: "Unknown"
  }

  MesaRow {
    visible: (root.info?.transform ?? "") !== ""
    label: "Transform"
    value: root.info?.transform ?? ""
  }

  MesaRow {
    visible: (root.info?.adaptive_sync_status ?? "") !== ""
    label: "Adaptive sync"
    value: root.info?.adaptive_sync_status ?? ""
    valueColor: root.info?.adaptive_sync_status === "enabled" ? ThemeService.colors.ok : ThemeService.colors.on_surface
  }
}

import Quickshell.I3

import qs.Services
import qs.Modules.Settings.Common

PanelSection {
  id: root

  readonly property I3Monitor monitor: I3.focusedMonitor
  readonly property var info: root.monitor?.lastIpcObject ?? null
  readonly property var mode: root.info?.current_mode ?? null

  title: "Output"

  PanelRow {
    label: "Name"
    value: root.monitor?.name || "Unknown"
    valueColor: root.monitor ? ThemeService.colors.foreground : ThemeService.colors.on_surface
  }

  PanelRow {
    label: "Resolution"
    value: root.mode ? `${root.mode.width}x${root.mode.height}` : "Unknown"
    valueColor: root.mode ? ThemeService.colors.foreground : ThemeService.colors.on_surface
  }

  PanelRow {
    label: "Refresh"
    // sway reports the refresh rate in mHz
    value: root.mode?.refresh > 0 ? `${(root.mode.refresh / 1000).toFixed(2)} Hz` : "Unknown"
    valueColor: root.mode?.refresh > 0 ? ThemeService.colors.foreground : ThemeService.colors.on_surface
  }

  PanelRow {
    label: "Scale"
    value: root.monitor ? root.monitor.scale.toFixed(2) : "Unknown"
    valueColor: root.monitor ? ThemeService.colors.foreground : ThemeService.colors.on_surface
  }

  PanelRow {
    visible: (root.info?.transform ?? "") !== ""
    label: "Transform"
    value: root.info?.transform ?? ""
    valueColor: ThemeService.colors.foreground
  }

  PanelRow {
    visible: (root.info?.adaptive_sync_status ?? "") !== ""
    label: "Adaptive sync"
    value: root.info?.adaptive_sync_status ?? ""
    valueColor: root.info?.adaptive_sync_status === "enabled" ? ThemeService.colors.ok : ThemeService.colors.on_surface
  }
}

import Quickshell.I3

import qs.Services
import qs.Modules.Settings.Common

PanelSection {
  id: root

  readonly property var info: I3.focusedMonitor?.lastIpcObject ?? null

  title: "Monitor"

  PanelRow {
    label: "Make"
    value: root.info?.make || "Unknown"
    valueColor: root.info?.make ? ThemeService.colors.foreground : ThemeService.colors.on_surface
  }

  PanelRow {
    label: "Model"
    value: root.info?.model || "Unknown"
    valueColor: root.info?.model ? ThemeService.colors.foreground : ThemeService.colors.on_surface
  }

  PanelRow {
    label: "Serial"
    value: root.info?.serial || "Unknown"
    valueColor: root.info?.serial ? ThemeService.colors.foreground : ThemeService.colors.on_surface
  }
}

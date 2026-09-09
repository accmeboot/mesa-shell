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
    valueColor: root.info?.make ? ConfigService.colors.foreground : ConfigService.colors.on_surface
  }

  PanelRow {
    label: "Model"
    value: root.info?.model || "Unknown"
    valueColor: root.info?.model ? ConfigService.colors.foreground : ConfigService.colors.on_surface
  }

  PanelRow {
    label: "Serial"
    value: root.info?.serial || "Unknown"
    valueColor: root.info?.serial ? ConfigService.colors.foreground : ConfigService.colors.on_surface
  }
}

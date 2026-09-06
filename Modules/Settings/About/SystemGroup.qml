import qs.Services
import qs.Modules.Settings.Common

PanelSection {
  title: "System"

  PanelRow {
    label: "OS"
    value: SystemService.distro || "Unknown"
    valueColor: SystemService.distro ? ConfigService.colors.foreground : ConfigService.colors.on_surface
  }

  PanelRow {
    label: "Kernel"
    value: SystemService.kernel || "Unknown"
    valueColor: SystemService.kernel ? ConfigService.colors.foreground : ConfigService.colors.on_surface
  }

  PanelRow {
    label: "Hostname"
    value: SystemService.hostname || "Unknown"
    valueColor: SystemService.hostname ? ConfigService.colors.foreground : ConfigService.colors.on_surface
  }

  PanelRow {
    label: "Session"
    value: SystemService.session || "Unknown"
    valueColor: SystemService.session ? ConfigService.colors.foreground : ConfigService.colors.on_surface
  }

  PanelRow {
    label: "Uptime"
    value: SystemService.uptime > 0 ? SystemService.formatUptime(SystemService.uptime) : "Unknown"
    valueColor: SystemService.uptime > 0 ? ConfigService.colors.foreground : ConfigService.colors.on_surface
  }
}

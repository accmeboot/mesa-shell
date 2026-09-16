import qs.Services
import qs.Components

MesaSection {
  title: "System"

  MesaRow {
    label: "OS"
    value: SystemService.distro || "Unknown"
    valueColor: SystemService.distro ? ThemeService.colors.foreground : ThemeService.colors.on_surface
  }

  MesaRow {
    label: "Kernel"
    value: SystemService.kernel || "Unknown"
    valueColor: SystemService.kernel ? ThemeService.colors.foreground : ThemeService.colors.on_surface
  }

  MesaRow {
    label: "Hostname"
    value: SystemService.hostname || "Unknown"
    valueColor: SystemService.hostname ? ThemeService.colors.foreground : ThemeService.colors.on_surface
  }

  MesaRow {
    label: "Session"
    value: SystemService.session || "Unknown"
    valueColor: SystemService.session ? ThemeService.colors.foreground : ThemeService.colors.on_surface
  }

  MesaRow {
    label: "Uptime"
    value: SystemService.uptime > 0 ? SystemService.formatUptime(SystemService.uptime) : "Unknown"
    valueColor: SystemService.uptime > 0 ? ThemeService.colors.foreground : ThemeService.colors.on_surface
  }
}

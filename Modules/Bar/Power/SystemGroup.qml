import qs.Services
import qs.Components

MesaSection {
  title: "System"

  MesaRow {
    label: "OS"
    value: SystemService.distro
    fallback: "Unknown"
  }

  MesaRow {
    label: "Kernel"
    value: SystemService.kernel
    fallback: "Unknown"
  }

  MesaRow {
    label: "Hostname"
    value: SystemService.hostname
    fallback: "Unknown"
  }

  MesaRow {
    label: "Session"
    value: SystemService.session
    fallback: "Unknown"
  }

  MesaRow {
    label: "Uptime"
    value: SystemService.uptime > 0 ? SystemService.formatUptime(SystemService.uptime) : ""
    fallback: "Unknown"
  }
}

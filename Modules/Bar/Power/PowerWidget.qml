import qs.Services
import qs.Components

MesaPanelWidget {
  panel: "power"
  icon: "system-shutdown"
  iconColor: ThemeService.colors.critical

  content: PowerPanel {
    onRequestClose: PanelService.close("power")
  }
}

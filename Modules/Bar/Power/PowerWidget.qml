import qs.Services
import qs.Components

MesaPanelWidget {
  panel: "power"
  icon: "system-shutdown"

  content: PowerPanel {
    onRequestClose: PanelService.close("power")
  }
}

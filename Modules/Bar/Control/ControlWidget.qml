import qs.Services
import qs.Components

MesaPanelWidget {
  panel: "control"
  icon: "pan-down"

  content: ControlPanel {
    onRequestClose: PanelService.close("control")
  }
}

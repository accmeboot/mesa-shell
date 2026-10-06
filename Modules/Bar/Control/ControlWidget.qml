import qs.Services
import qs.Components

MesaPanelWidget {
  panel: "control"
  icon: "faders"

  content: ControlPanel {
    onRequestClose: PanelService.close("control")
  }
}

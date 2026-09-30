import qs.Services
import qs.Components

MesaPanelWidget {
  panel: "control"
  icon: "preferences-system"

  content: ControlPanel {
    onRequestClose: PanelService.close("control")
  }
}

import QtQuick

import qs.Services
import qs.Components

MesaPanelWidget {
  panel: "control"
  icon: "faders"

  Component.onCompleted: BrightnessService.refresh()

  content: ControlPanel {
    onRequestClose: PanelService.close("control")
  }
}

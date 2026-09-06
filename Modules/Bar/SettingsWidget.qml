import Quickshell
import QtQuick

import qs.Services
import qs.Components

MesaButton {
  icon: SettingsService.isOpen ? "cross" : "settings"

  onClicked: SettingsService.toggle()
}

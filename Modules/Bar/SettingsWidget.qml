import Quickshell
import QtQuick

import qs.Services
import qs.Components

MesaButton {
  icon: SettingsService.isOpen ? "window-close" : "settings"

  onClicked: SettingsService.toggle()
}

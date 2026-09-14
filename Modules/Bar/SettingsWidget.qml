import Quickshell
import QtQuick

import qs.Services
import qs.Components

MesaButton {
  id: root

  required property var screen

  icon: SettingsService.isOpen ? "window-close" : "settings"

  onClicked: SettingsService.toggle(root.screen.name)
}

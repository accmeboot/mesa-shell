import Quickshell
import QtQuick

import qs.Services
import qs.Components

MesaButton {
  icon: "invertimage"

  onClicked: ThemeService.isDark ? ThemeService.light() : ThemeService.dark()
}

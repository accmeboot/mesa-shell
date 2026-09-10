import Quickshell
import QtQuick

import qs.Services
import qs.Components

MesaButton {
  icon: "lighttable"

  onClicked: ThemeService.isDark ? ThemeService.light() : ThemeService.dark()
}

import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

import qs.Components
import qs.Services

RowLayout {
  id: trayRow

  readonly property bool menuOpen: trayMenu.isOpen

  property bool isVisible: false

  spacing: 0

  onIsVisibleChanged: if (!trayRow.isVisible) trayMenu.close()

  visible: Boolean(SystemTray.items.values.length)

  Repeater {
    model: SystemTray.items

    MesaButton {
      id: item

      required property SystemTrayItem modelData

      visible: trayRow.isVisible

      acceptedButtons: Qt.LeftButton | Qt.RightButton

      text: {
        var appName = item.modelData.title || item.modelData.tooltipTitle || item.modelData.id;
        const hasUnderscore = appName.includes("_")

        if (hasUnderscore) {
          appName = appName.substring(0, item.modelData.id.indexOf("_"));
        }

        return appName.toLowerCase()
      }

      onClicked: mouse => {
        if (mouse.button === Qt.LeftButton && !item.modelData.onlyMenu) {
          item.modelData.activate();
        } else if (item.modelData.hasMenu) {
          trayMenu.openAt(item, item.modelData.menu);
        }
      }
    }
  }

  MesaMenu {
    id: trayMenu
  }

  MesaButton {
    icon: trayRow.isVisible ? "cross" : "menu"
    onClicked: trayRow.isVisible = !trayRow.isVisible
  }
}

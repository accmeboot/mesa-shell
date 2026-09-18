import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

import qs.Components
import qs.Services

RowLayout {
  id: trayRow

  required property var screen

  readonly property bool menuOpen: trayMenu.isOpen
  readonly property int collapsedWidth: toggle.implicitWidth

  property bool isVisible: false

  spacing: 0

  onIsVisibleChanged: if (!trayRow.isVisible) trayMenu.close()
  onMenuOpenChanged: if (trayRow.menuOpen) trayRow.forceActiveFocus()

  Keys.onEscapePressed: trayMenu.close()

  visible: Boolean(SystemTray.items.values.length)

  Repeater {
    model: SystemTray.items

    MesaButton {
      id: item

      required property SystemTrayItem modelData

      visible: trayRow.isVisible

      Layout.fillWidth: true
      Layout.maximumWidth: item.implicitWidth
      Layout.minimumWidth: item.horizontalPadding * 2 + Math.round(ConfigService.font.size * 2)

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

  MesaCatcher {
    active: trayMenu.isOpen
    layer: WlrLayer.Overlay
    namespace: "mesa-tray-catcher"
    exclude: trayRow
    excludeScreen: trayRow.screen

    onDismissed: trayMenu.close()
  }

  MesaButton {
    id: toggle

    Layout.fillHeight: true
    icon: trayRow.isVisible ? "window-close" : "view-more-horizontal"
    onClicked: trayRow.isVisible = !trayRow.isVisible
  }
}

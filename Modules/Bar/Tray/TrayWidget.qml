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
  readonly property bool ipcOpen: PanelService.current === "tray" && PanelService.screen === trayRow.screen.name

  function menuItems(): var {
    const list = [];

    for (let i = 0; i < items.count; i++) {
      const item = items.itemAt(i);

      if (item?.modelData?.hasMenu) list.push(item);
    }

    return list;
  }

  function openMenu(item): void {
    trayMenu.openAt(item, item.modelData.menu);
    trayMenu.autoSelect = true;

    if (trayMenu.shouldShow) trayMenu.selectFirst();
  }

  function openFirstMenu(): void {
    const list = trayRow.menuItems();

    if (list.length === 0) {
      PanelService.close("tray");
      return;
    }

    trayRow.openMenu(list[0]);
  }

  function stepMenu(delta: int): void {
    const list = trayRow.menuItems();

    if (list.length < 2) return;

    const current = list.indexOf(trayMenu.anchorItem);
    const index = current < 0 ? (delta > 0 ? 0 : list.length - 1) : (current + delta + list.length) % list.length;

    trayRow.openMenu(list[index]);
  }

  function handleMenuClosed(): void {
    if (trayRow.menuOpen || !trayRow.ipcOpen) return;

    PanelService.close("tray");
  }

  spacing: 0

  onIpcOpenChanged: trayRow.ipcOpen ? Qt.callLater(trayRow.openFirstMenu) : trayMenu.close()

  onMenuOpenChanged: {
    if (trayRow.menuOpen) {
      trayRow.forceActiveFocus();
      return;
    }

    Qt.callLater(trayRow.handleMenuClosed);
  }

  Keys.onEscapePressed: trayMenu.close()
  Keys.onDownPressed: trayMenu.activeMenu().step(1)
  Keys.onUpPressed: trayMenu.activeMenu().step(-1)
  Keys.onReturnPressed: trayMenu.activeMenu().activate()
  Keys.onEnterPressed: trayMenu.activeMenu().activate()
  Keys.onSpacePressed: trayMenu.activeMenu().activate()

  Keys.onPressed: event => {
    const shift = (event.modifiers & Qt.ShiftModifier) !== 0;

    switch (event.key) {
    case Qt.Key_J:
      trayMenu.activeMenu().step(1);
      break;
    case Qt.Key_K:
      trayMenu.activeMenu().step(-1);
      break;
    case Qt.Key_H:
    case Qt.Key_Left:
      shift ? trayRow.stepMenu(-1) : trayMenu.closeSubmenu();
      break;
    case Qt.Key_L:
    case Qt.Key_Right:
      shift ? trayRow.stepMenu(1) : trayMenu.activeMenu().enterSubmenu();
      break;
    default:
      return;
    }

    event.accepted = true;
  }

  visible: Boolean(SystemTray.items.values.length)

  Repeater {
    id: items

    model: SystemTray.items

    MesaButton {
      id: item

      required property SystemTrayItem modelData

      Layout.fillWidth: true
      Layout.maximumWidth: item.implicitWidth
      Layout.minimumWidth: item.horizontalPadding * 2 + Math.round(ConfigService.font.size * 2)

      acceptedButtons: Qt.LeftButton | Qt.RightButton
      open: trayMenu.isOpen && trayMenu.anchorItem === item

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
}

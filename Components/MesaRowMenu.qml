import QtQuick
import Quickshell

import qs.Services

Scope {
  id: root

  default property list<MesaMenuEntry> entries

  property Item anchorItem: null
  property bool open: false

  readonly property bool isOpen: root.open
  readonly property var visibleEntries: root.entries.filter(entry => entry.visible)

  function showAt(item: Item): void {
    if (root.open && root.anchorItem === item) return;

    root.anchorItem = item;
    root.open = true;

    MenuService.open(root);

    surface.selectFirst();
  }

  function toggleAt(item: Item): void {
    if (root.open && root.anchorItem === item) {
      MenuService.close();
      return;
    }

    root.showAt(item);
  }

  function close(): void {
    root.open = false;
    surface.currentIndex = -1;

    MenuService.release(root);
  }

  function step(delta: int): void {
    surface.step(delta);
  }

  function activate(): void {
    surface.activate();
  }

  function adjust(delta: int): void {
    surface.adjust(delta);
  }

  MesaMenuSurface {
    id: surface

    entries: root.visibleEntries
    active: root.isOpen
    anchorItem: root.anchorItem
    submenu: true

    onTriggered: index => {
      const entry = surface.entryAt(index);

      if (!entry) return;

      entry.triggered();
      MenuService.close();
    }

    onEntered: index => surface.currentIndex = index

    onBackerHidden: MenuService.close()
  }
}

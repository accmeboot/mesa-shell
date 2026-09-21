import Quickshell
import QtQuick

Scope {
  id: root

  property QsMenuHandle menuHandle: null
  property Item anchorItem: null
  property bool submenu: false
  property var parentMenu: null
  property bool autoSelect: false
  property Item openRow: null

  readonly property bool isOpen: root.menuHandle !== null
  readonly property bool shouldShow: surface.shouldShow

  onShouldShowChanged: if (root.shouldShow && root.autoSelect) root.selectFirst()

  onOpenRowChanged: {
    if (!submenuLoader.item) {
      if (!root.openRow) return;

      submenuLoader.setSource(Qt.resolvedUrl("MesaMenu.qml"), {
        submenu: true,
        parentMenu: root,
        anchorItem: root.openRow,
        menuHandle: root.openRow.modelData
      });

      return;
    }

    const submenu = submenuLoader.item;

    submenu.menuHandle = null;

    if (!root.openRow) return;

    submenu.anchorItem = root.openRow;
    submenu.menuHandle = root.openRow.modelData;
  }

  function selectFirst(): void {
    surface.selectFirst();
  }

  function step(delta: int): void {
    surface.step(delta);
  }

  function activate(): void {
    surface.activate();
  }

  function openSubmenu(index: int): void {
    root.openRow = surface.rowAt(index);

    const submenu = submenuLoader.item;

    if (!submenu) return;

    submenu.autoSelect = true;

    if (submenu.shouldShow) submenu.selectFirst();
  }

  function enterSubmenu(): void {
    const entry = surface.entryAt(surface.currentIndex);

    if (!entry || !entry.enabled || !entry.hasChildren) return;

    root.openSubmenu(surface.currentIndex);
  }

  function closeSubmenu(): void {
    const menu = root.activeMenu();

    if (menu.parentMenu) menu.parentMenu.openRow = null;
  }

  function activeMenu(): var {
    const submenu = submenuLoader.item;

    return submenu && submenu.isOpen ? submenu.activeMenu() : root;
  }

  function openAt(item, handle): void {
    const toggle = root.isOpen && root.anchorItem === item;
    root.close();

    if (toggle) return;

    root.anchorItem = item;
    root.menuHandle = handle;
  }

  function close(): void {
    root.openRow = null;
    surface.currentIndex = -1;
    root.autoSelect = false;
    submenuLoader.source = "";
    root.menuHandle = null;
  }

  function closeAll(): void {
    if (root.parentMenu) root.parentMenu.closeAll();
    else root.close();
  }

  QsMenuOpener {
    id: opener

    menu: root.menuHandle
  }

  Loader { id: submenuLoader }

  MesaMenuSurface {
    id: surface

    entries: opener.children.values
    active: root.isOpen
    anchorItem: root.anchorItem
    submenu: root.submenu

    onTriggered: index => {
      const entry = surface.entryAt(index);

      if (!entry) return;

      entry.triggered();
      root.closeAll();
    }

    onSubmenuRequested: index => root.openSubmenu(index)

    onEntered: index => {
      surface.currentIndex = index;

      const entry = surface.entryAt(index);

      root.openRow = entry && entry.hasChildren ? surface.rowAt(index) : null;
    }

    onBackerHidden: root.closeAll()
  }
}

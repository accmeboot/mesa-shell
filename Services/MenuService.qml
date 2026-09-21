pragma Singleton

import Quickshell

Singleton {
  id: root

  property var current: null

  readonly property bool isOpen: root.current !== null

  function open(menu): void {
    if (root.current === menu) return;

    const previous = root.current;

    root.current = menu;

    if (previous) previous.close();
  }

  function release(menu): void {
    if (root.current === menu) root.current = null;
  }

  function close(): void {
    const menu = root.current;

    if (!menu) return;

    root.current = null;
    menu.close();
  }
}

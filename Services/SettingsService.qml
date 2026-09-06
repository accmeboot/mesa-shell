pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
  id: root

  readonly property string home: ""
  readonly property var views: ["audio", "network", "bluetooth", "about"]

  property bool isOpen: false
  property string view: root.home

  function open(): void {
    root.isOpen = true;
  }

  function close(): void {
    root.isOpen = false;
    root.view = root.home;
  }

  function toggle(): void {
    if (root.isOpen) root.close();
    else root.open();
  }

  function navigate(view: string): void {
    root.view = root.views.includes(view) ? view : root.home;
  }

  function back(): void {
    root.view = root.home;
  }

  function openView(view: string): void {
    root.navigate(view);
    root.isOpen = true;
  }

  IpcHandler {
    target: "settingsWindow"

    function open(): void {
      root.open();
    }

    function close(): void {
      root.close();
    }

    function toggle(): void {
      root.toggle();
    }

    function view(name: string): void {
      root.openView(name);
    }
  }
}

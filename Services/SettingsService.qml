pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
  id: root

  readonly property string home: ""
  readonly property var views: ["audio", "display", "network", "bluetooth", "about"]

  property bool isOpen: false
  property string view: root.home
  property string screen: ""

  function open(screen: string): void {
    root.screen = screen;
    root.isOpen = true;
  }

  function close(): void {
    root.isOpen = false;
    root.view = root.home;
  }

  function toggle(screen: string): void {
    if (root.isOpen) root.close();
    else root.open(screen);
  }

  function navigate(view: string): void {
    root.view = root.views.includes(view) ? view : root.home;
  }

  function back(): void {
    root.view = root.home;
  }

  function openView(view: string, screen: string): void {
    root.navigate(view);
    root.open(screen);
  }

  IpcHandler {
    target: "settingsWindow"

    function open(): void {
      root.open(SwayService.focusedOutput);
    }

    function close(): void {
      root.close();
    }

    function toggle(): void {
      root.toggle(SwayService.focusedOutput);
    }

    function view(name: string): void {
      root.openView(name, SwayService.focusedOutput);
    }
  }
}

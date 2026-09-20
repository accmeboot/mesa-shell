pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property string current: ""
  property string screen: ""

  function open(panel: string, screen: string): void {
    root.current = panel;
    root.screen = screen;
  }

  function close(panel: string): void {
    if (panel !== "" && root.current !== panel) return;

    root.current = "";
    root.screen = "";
  }

  function toggle(panel: string, screen: string): void {
    if (root.current === panel && root.screen === screen) {
      root.close(panel);
      return;
    }

    root.open(panel, screen);
  }

  IpcHandler {
    target: "panel"

    function toggle(panel: string): void {
      root.toggle(panel, SwayService.focusedOutput);
    }

    function open(panel: string): void {
      root.open(panel, SwayService.focusedOutput);
    }

    function close(): void {
      root.close("");
    }
  }
}

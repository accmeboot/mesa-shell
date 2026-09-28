pragma Singleton

import Quickshell

Singleton {
  id: root

  readonly property string name: {
    if ((Quickshell.env("XDG_CURRENT_DESKTOP") ?? "").split(":").includes("dwl")) return "dwl";

    return "";
  }

  readonly property var backend: {
    if (root.name === "dwl") return DwlService;

    return null;
  }

  readonly property string focusedOutput: root.backend?.focusedOutput || (Quickshell.screens[0]?.name ?? "")
  readonly property string exitCommand: root.backend?.exitCommand ?? "loginctl terminate-session \"$XDG_SESSION_ID\""

  function workspaces(output: string): var {
    return root.backend?.workspaces(output) ?? [];
  }

  function layouts(output: string): var {
    return root.backend?.layouts(output) ?? [];
  }

  function currentLayout(output: string): var {
    return root.layouts(output).find((layout) => layout.current) ?? null;
  }

  function setLayout(output: string, index: int): void {
    root.backend?.setLayout(output, index);
  }

  function outputInfo(output: string): var {
    return root.backend?.outputInfo(output) ?? null;
  }

  function refreshOutputs(): void {
    root.backend?.refreshOutputs();
  }
}

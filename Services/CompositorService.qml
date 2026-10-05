pragma Singleton

import Quickshell

Singleton {
  id: root

  readonly property string name: {
    if ((Quickshell.env("XDG_CURRENT_DESKTOP") ?? "").split(":").includes("sway")) return "sway";

    return "";
  }

  readonly property var backend: {
    if (root.name === "sway") return SwayService;

    return null;
  }

  readonly property string focusedOutput: root.backend?.focusedOutput || (Quickshell.screens[0]?.name ?? "")
  readonly property string exitCommand: root.backend?.exitCommand ?? "loginctl terminate-session \"$XDG_SESSION_ID\""
  readonly property string mode: root.backend?.mode ?? ""

  function workspaces(output: string): var {
    return root.backend?.workspaces(output) ?? [];
  }
}

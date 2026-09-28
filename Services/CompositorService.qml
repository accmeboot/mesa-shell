pragma Singleton

import Quickshell

Singleton {
  id: root

  readonly property string name: {
    if (Quickshell.env("SWAYSOCK")) return "sway";
    if ((Quickshell.env("XDG_CURRENT_DESKTOP") ?? "").split(":").includes("dwl")) return "dwl";

    return "";
  }

  readonly property var backend: {
    if (root.name === "sway") return SwayService;
    if (root.name === "dwl") return DwlService;

    return null;
  }

  readonly property string focusedOutput: root.backend?.focusedOutput || (Quickshell.screens[0]?.name ?? "")
  readonly property string mode: root.backend?.mode ?? ""
  readonly property string exitCommand: root.backend?.exitCommand ?? "loginctl terminate-session \"$XDG_SESSION_ID\""

  function workspaces(output: string): var {
    if (root.name === "dwl") {
      return DwlService.tags(output).map((tag) => ({
        name: String(tag.index + 1),
        focused: tag.selected && output === root.focusedOutput,
        active: tag.selected,
        occupied: tag.occupied,
        holdsFocus: tag.focusedClient,
        monitor: output,
        number: tag.index + 1,
        urgent: tag.urgent,
        activate: () => DwlService.viewTag(output, tag.index),
        toggle: () => DwlService.toggleTag(output, tag.index),
      }));
    }

    return root.backend?.workspaces(output) ?? [];
  }

  function layout(output: string): string {
    return root.backend?.layout(output) ?? "";
  }

  function cycleLayout(output: string): void {
    root.backend?.cycleLayout(output);
  }

  function outputInfo(output: string): var {
    return root.backend?.outputInfo(output) ?? null;
  }

  function refreshOutputs(): void {
    root.backend?.refreshOutputs();
  }
}

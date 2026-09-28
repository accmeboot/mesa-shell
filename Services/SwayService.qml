pragma Singleton

import Quickshell
import Quickshell.I3
import Quickshell.Io

Singleton {
  id: root

  readonly property string focusedOutput: I3.focusedMonitor?.name ?? ""
  readonly property string exitCommand: "swaymsg exit"

  property string mode: "default"

  function workspaces(output: string): var {
    const existingWorkspaces = I3.workspaces.values
    .filter((ws) => ws.monitor?.name === output)
    .map((ws) => ({
      name: ws.name,
      focused: ws.focused,
      active: ws.active,
      monitor: ws.monitor.name,
      number: ws.number,
      urgent: ws.urgent,
      activate: () => I3.dispatch(`workspace ${ws.name}`),
    }))

    return existingWorkspaces.sort((a, b) => a.number - b.number)
  }

  function layout(output: string): string {
    return "";
  }

  function cycleLayout(output: string): void {}

  function outputInfo(output: string): var {
    const monitor = I3.monitors.values.find((m) => m.name === output);
    if (!monitor) return null;

    const info = monitor.lastIpcObject ?? {};
    const mode = info.current_mode ?? null;

    return {
      name: monitor.name,
      make: info.make ?? "",
      model: info.model ?? "",
      serial: info.serial ?? "",
      width: mode?.width ?? 0,
      height: mode?.height ?? 0,
      // sway reports the refresh rate in mHz
      refresh: mode?.refresh > 0 ? mode.refresh / 1000 : 0,
      scale: monitor.scale,
      transform: info.transform ?? "",
      adaptiveSync: info.adaptive_sync_status ?? "",
    };
  }

  function refreshOutputs(): void {}

  I3IpcListener {
    subscriptions: ["mode"]
    onIpcEvent: event => {
      if (event.data) {
        try {
          const data = JSON.parse(event.data)

          if (data?.change) {
            root.mode = data.change
          }
        } catch (e) {
          console.error(e)
        }
      }
    }
  }
}

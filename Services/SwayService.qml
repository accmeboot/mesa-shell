pragma Singleton

import QtQuick
import Quickshell
import Quickshell.I3
import Quickshell.Io

Singleton {
  id: root

  property string mode: "default"

  readonly property string focusedOutput: I3.focusedMonitor?.name ?? ""
  readonly property string exitCommand: "swaymsg exit"

  function workspaces(output: string): var {
    return I3.workspaces.values
      .filter((workspace) => workspace.monitor?.name === output)
      .sort((a, b) => a.number - b.number)
      .map((workspace) => ({
        name: workspace.name,
        focused: workspace.focused,
        active: workspace.active,
        monitor: output,
        number: workspace.number,
        urgent: workspace.urgent,
        activate: () => workspace.activate(),
      }));
  }

  I3IpcListener {
    subscriptions: ["mode"]

    onIpcEvent: (event) => {
      if (event.type === "mode") root.mode = JSON.parse(event.data).change;
    }
  }

  Process {
    command: ["swaymsg", "-t", "get_binding_state"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: root.mode = JSON.parse(this.text).name
    }
  }
}

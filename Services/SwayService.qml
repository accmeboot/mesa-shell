pragma Singleton

import Quickshell
import Quickshell.I3
import Quickshell.Io

Singleton {
  id: root

  readonly property string focusedOutput: I3.focusedMonitor?.name ?? ""

  property string mode: "defulat"

  function getWorkspacesForMonitor(monitor: string): var {
    const existingWorkspaces = I3.workspaces.values
    .filter((ws) => ws.monitor?.name === monitor)
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

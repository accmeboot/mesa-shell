pragma Singleton

import QtQuick
import Quickshell
import Quickshell.I3
import Quickshell.Io

Singleton {
  id: root

  property string mode: "default"
  property var windows: []
  property bool windowsStale: false

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

  function refreshWindows(): void {
    if (tree.running) root.windowsStale = true;
    else tree.running = true;
  }

  function collectWindows(node, active: bool): var {
    const children = [...node.nodes, ...node.floating_nodes].reduce((all, child) => all.concat(root.collectWindows(child, active && node.focus[0] === child.id)), []);

    if (node.pid === undefined) return children;

    return [{
      appId: node.app_id ?? node.window_properties?.class ?? "",
      title: node.name ?? "",
      urgent: node.urgent,
      focused: active,
      activate: () => I3.dispatch(`[con_id=${node.id}] focus`),
    }, ...children];
  }

  I3IpcListener {
    subscriptions: ["mode", "window", "workspace"]

    onIpcEvent: (event) => {
      if (event.type === "mode") root.mode = JSON.parse(event.data).change;
      if (event.type === "window" || event.type === "workspace") root.refreshWindows();
    }
  }

  Process {
    id: tree

    command: ["swaymsg", "-t", "get_tree"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: root.windows = root.collectWindows(JSON.parse(this.text), true)
    }

    onExited: {
      if (!root.windowsStale) return;

      root.windowsStale = false;
      tree.running = true;
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

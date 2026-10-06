pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
  id: root

  property bool fuserAvailable: false
  property var deviceUsers: []

  readonly property var pipewireUsers: {
    const users = [];

    for (const group of Pipewire.linkGroups.values) {
      const source = group.source;
      const target = group.target;

      if (!source || !target) continue;

      if (source.type === PwNodeType.AudioSource && target.type === PwNodeType.AudioInStream) {
        users.push({ kind: "mic", app: root.appName(target) });
      } else if (source.type === PwNodeType.VideoSource) {
        users.push({ kind: source.properties["device.api"] ? "camera" : "screen", app: root.appName(target) });
      }
    }

    return users;
  }

  readonly property var apps: {
    const apps = new Map();

    for (const user of root.pipewireUsers.concat(root.deviceUsers)) {
      const key = user.app.toLowerCase();

      if (!apps.has(key)) apps.set(key, { app: user.app, kinds: [] });

      const kinds = apps.get(key).kinds;

      if (!kinds.includes(user.kind)) kinds.push(user.kind);
    }

    return [...apps.values()];
  }

  readonly property bool active: root.apps.length > 0

  function cleanName(name: string): string {
    return name.replace(/^\./, "").replace(/-wrapped$/, "");
  }

  function appName(node): string {
    const props = node.properties;

    return root.cleanName(props["application.name"] || props["application.process.binary"] || node.description || node.name || "Unknown");
  }

  function parseDevices(text: string): void {
    const users = [];

    for (const line of text.split("\n")) {
      const comm = line.trim();

      if (!comm || /^(pipewire|wireplumber)/.test(comm)) continue;

      users.push({ kind: "camera", app: root.cleanName(comm) });
    }

    root.deviceUsers = users;
  }

  Process {
    running: true
    command: ["sh", "-c", "command -v fuser"]

    onExited: code => root.fuserAvailable = code === 0
  }

  Process {
    id: scan

    command: ["sh", "-c", "for d in /dev/video*; do [ -e \"$d\" ] || continue; for p in $(fuser \"$d\" 2>/dev/null); do cat /proc/$p/comm 2>/dev/null; done; done"]

    stdout: StdioCollector {
      onStreamFinished: root.parseDevices(this.text)
    }
  }

  Timer {
    interval: 2000
    running: root.fuserAvailable
    repeat: true
    triggeredOnStart: true

    onTriggered: scan.running = true
  }
}

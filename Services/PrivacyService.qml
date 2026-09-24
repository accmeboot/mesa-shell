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
        users.push({ kind: "mic", app: root.appName(target), device: source.description || source.name });
      } else if (source.type === PwNodeType.VideoSource) {
        const camera = Boolean(source.properties["device.api"]);

        users.push({ kind: camera ? "camera" : "screen", app: root.appName(target), device: camera ? source.description || source.name : "" });
      }
    }

    return users;
  }

  readonly property var users: root.unique(root.pipewireUsers.concat(root.deviceUsers))

  readonly property var micUsers: root.users.filter(user => user.kind === "mic")
  readonly property var cameraUsers: root.users.filter(user => user.kind === "camera")
  readonly property var screenUsers: root.users.filter(user => user.kind === "screen")

  readonly property bool micActive: root.micUsers.length > 0
  readonly property bool cameraActive: root.cameraUsers.length > 0
  readonly property bool screenActive: root.screenUsers.length > 0
  readonly property bool active: root.micActive || root.cameraActive || root.screenActive

  function cleanName(name: string): string {
    return name.replace(/^\./, "").replace(/-wrapped$/, "");
  }

  function appName(node): string {
    const props = node.properties;

    return root.cleanName(props["application.name"] || props["application.process.binary"] || node.description || node.name || "Unknown");
  }

  function unique(users: var): var {
    const seen = new Set();

    return users.filter(user => {
      const key = `${user.kind}\t${user.app.toLowerCase()}\t${user.device}`;

      if (seen.has(key)) return false;

      seen.add(key);
      return true;
    });
  }

  function parseDevices(text: string): void {
    const users = [];

    for (const line of text.split("\n")) {
      const [device, comm] = line.split("\t");

      if (!device || !comm || /^(pipewire|wireplumber)/.test(comm)) continue;

      users.push({ kind: "camera", app: root.cleanName(comm), device: device });
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

    command: ["sh", "-c", "for d in /dev/video*; do [ -e \"$d\" ] || continue; for p in $(fuser \"$d\" 2>/dev/null); do printf '%s\\t%s\\n' \"$d\" \"$(cat /proc/$p/comm 2>/dev/null)\"; done; done"]

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

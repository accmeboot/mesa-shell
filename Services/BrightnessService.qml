pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  readonly property bool available: root.device !== ""

  property string device: ""
  property int max: 0
  property real percentage: 0

  // brightnessctl writes take a moment, so drags are coalesced: `requested`
  // holds the latest value the user asked for, `applied` the one in flight.
  property int requested: -1
  property int applied: -1

  function refresh(): void {
    if (query.running) return;

    query.running = true;
  }

  function setPercentage(fraction: real): void {
    root.percentage = Math.max(0, Math.min(1, fraction));
    root.requested = Math.round(root.percentage * 100);

    root.flush();
  }

  function flush(): void {
    if (!root.available || setter.running) return;
    if (root.requested < 0 || root.requested === root.applied) return;

    root.applied = root.requested;
    setter.command = ["brightnessctl", "-m", "-c", "backlight", "set", `${root.applied}%`];
    setter.running = true;
  }

  // brightnessctl -m prints "<device>,<class>,<current>,<percent>%,<max>"
  function parse(output: string): void {
    const line = output.trim().split("\n")[0];

    if (!line) return;

    const fields = line.split(",");

    if (fields.length < 5) return;

    const max = Number(fields[4]);

    if (!(max > 0)) return;

    root.device = fields[0];
    root.max = max;

    // a write in flight is newer than anything the device reports back
    if (!setter.running) root.percentage = Number(fields[2]) / max;
  }

  Process {
    id: query

    command: ["brightnessctl", "-m", "-c", "backlight", "i"]

    stdout: StdioCollector {
      onStreamFinished: root.parse(this.text)
    }
  }

  Process {
    id: setter

    stdout: StdioCollector {
      onStreamFinished: root.parse(this.text)
    }

    onExited: root.flush()
  }

  Component.onCompleted: root.refresh()
}

import Quickshell
import Quickshell.Io

Scope {
  id: root

  readonly property bool registered: root.acknowledged
  property bool acknowledged: false

  Process {
    id: agent

    running: true
    command: ["bluetoothctl", "--agent", "NoInputNoOutput"]
    stdinEnabled: true

    stdout: SplitParser {
      onRead: data => {
        if (data.includes("Agent registered")) root.acknowledged = true;
      }
    }

    onExited: root.acknowledged = false
  }
}

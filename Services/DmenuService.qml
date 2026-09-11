pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property bool isOpen: false
  property var applications: []
  property string mode: "run"
  property var items: []
  property var client: null

  function open(): void {
    loadApplications();
    isOpen = true;
  }

  function close(): void {
    if (client) {
      resolve("");
      return;
    }
    isOpen = false;
  }

  function choose(socket, lines): void {
    if (lines.length === 0) {
      socket.connected = false;
      return;
    }
    if (client) {
      resolve("");
    }
    client = socket;
    items = lines;
    mode = "choose";
    isOpen = true;
  }

  function resolve(value: string): void {
    const socket = client;
    client = null;
    isOpen = false;
    mode = "run";
    items = [];
    if (!socket) {
      return;
    }
    if (value !== "") {
      socket.write(value + "\n");
      socket.flush();
    }
    socket.connected = false;
  }

  SocketServer {
    active: true
    path: `${Quickshell.env("XDG_RUNTIME_DIR")}/mesa-shell-dmenu.sock`

    handler: Socket {
      id: request

      parser: SplitParser {
        splitMarker: "\0"
        onRead: data => root.choose(request, data.split("\n").filter(line => line !== ""))
      }

      onConnectionStateChanged: {
        if (connected) {
          return;
        }
        if (root.client === request) {
          root.resolve("");
        }
      }
    }
  }

  function execute(command: string): void {
    executionProcess.command = ["sh", "-lc", "setsid -f " + command + " >/dev/null 2>&1"];
    executionProcess.running = true;
    close();
  }

  Process {
    id: executionProcess
  }

  function loadApplications(): void {
    if (applicationsProcess.running) {
      return;
    }
    applicationsProcess.running = true;
  }

  Process {
    id: applicationsProcess
    command: ["sh", "-c", "ls $(echo $PATH | tr ':' ' ') 2>/dev/null | grep -v '/' | grep . | sort -u"]

    stdout: StdioCollector {
      id: collector

      onStreamFinished: () => {
        root.applications = this.text.trim().split('\n').filter(app => app.length > 0);
      }
    }
  }

  Component.onCompleted: {
    loadApplications();
  }

  IpcHandler {
    target: "dmenu"

    function open(): void {
      root.open();
    }

    function close(): void {
      root.close();
    }

    function toggle(): void {
      root.isOpen ? root.close() : root.open();
    }
  }
}

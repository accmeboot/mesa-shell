pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property bool isOpen: false
  property var applications: []

  function open(): void {
    loadApplications();
    isOpen = true;
  }

  function close(): void {
    isOpen = false;
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

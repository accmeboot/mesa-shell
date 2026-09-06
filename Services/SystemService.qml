pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  readonly property string session: Quickshell.env("XDG_CURRENT_DESKTOP") || Quickshell.env("XDG_SESSION_DESKTOP") || ""

  property string distro: ""
  property string kernel: ""
  property string hostname: ""
  property real uptime: 0

  function formatUptime(seconds: real): string {
    const days = Math.floor(seconds / 86400);
    const hours = Math.floor(seconds % 86400 / 3600);
    const minutes = Math.floor(seconds % 3600 / 60);

    const parts = [];

    if (days > 0) parts.push(`${days}d`);
    if (hours > 0) parts.push(`${hours}h`);
    parts.push(`${minutes}m`);

    return parts.join(" ");
  }

  FileView {
    path: "/etc/os-release"

    onLoaded: {
      const match = text().match(/^PRETTY_NAME="?(.*?)"?$/m);
      if (match) root.distro = match[1];
    }

    Component.onCompleted: reload()
  }

  FileView {
    path: "/proc/sys/kernel/osrelease"

    onLoaded: root.kernel = text().trim()

    Component.onCompleted: reload()
  }

  FileView {
    path: "/proc/sys/kernel/hostname"

    onLoaded: root.hostname = text().trim()

    Component.onCompleted: reload()
  }

  FileView {
    id: uptimeFile

    path: "/proc/uptime"

    onLoaded: root.uptime = Number(text().split(/\s+/)[0])

    Component.onCompleted: reload()
  }

  Timer {
    interval: 30000
    running: true
    repeat: true

    onTriggered: uptimeFile.reload()
  }
}

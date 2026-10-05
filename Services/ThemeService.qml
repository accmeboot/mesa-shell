pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property string polarity: ""

  // GTK3, Qt and the icon theme don't follow color-scheme on their own
  onPolarityChanged: if (root.polarity) applier.exec([Quickshell.shellPath("mshell"), "apply", root.polarity])

  readonly property bool isDark: root.polarity !== "light"
  readonly property JsonObject colors: root.polarity === "light" ? ConfigService.colors.light : ConfigService.colors.dark
  readonly property color muted: Qt.alpha(root.colors.foreground, 0.6)
  readonly property color disabled: Qt.alpha(root.colors.foreground, 0.4)
  readonly property url wallpaper: {
    if (!ConfigService.settled) return "";

    return ConfigService.toUrl(root.polarity === "light" ? ConfigService.wallpaper.light : ConfigService.wallpaper.dark);
  }

  function toggle(): void {
    if (setter.running) return;

    setter.command = ["gsettings", "set", "org.gnome.desktop.interface", "color-scheme", root.isDark ? "prefer-light" : "prefer-dark"];
    setter.running = true;
  }

  IpcHandler {
    target: "theme"

    function toggle(): void {
      root.toggle();
    }

    function isDark(): bool {
      return root.isDark;
    }
  }

  Process {
    command: ["sh", "-c", "gsettings get org.gnome.desktop.interface color-scheme && exec gsettings monitor org.gnome.desktop.interface color-scheme"]
    running: true

    stdout: SplitParser {
      onRead: line => root.polarity = line.includes("prefer-dark") ? "dark" : "light"
    }
  }

  Process {
    id: setter
  }

  Process {
    id: applier
  }
}

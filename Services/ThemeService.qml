pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property string polarity: ""

  readonly property bool isDark: root.polarity !== "light"
  readonly property JsonObject colors: root.polarity === "light" ? ConfigService.colors.light : ConfigService.colors.dark

  function run(command: string): void {
    if (!command) return;

    process.command = ["sh", "-c", command];
    process.running = true;
  }

  function dark(): void {
    if (process.running) return;

    root.polarity = "dark";
    root.run(ConfigService.hooks.onDarkThemeSet);
  }

  function light(): void {
    if (process.running) return;

    root.polarity = "light";
    root.run(ConfigService.hooks.onLightThemeSet);
  }

  Connections {
    target: ConfigService

    function onSettledChanged(): void {
      if (!root.polarity) root.polarity = ConfigService.defaultPolarity;
    }
  }

  Process {
    id: process
  }
}

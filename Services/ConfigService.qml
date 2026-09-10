pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  readonly property alias colors: adapter.colors
  readonly property alias font: adapter.font
  readonly property alias spacing: adapter.spacing
  readonly property alias border: adapter.border
  readonly property alias hooks: adapter.hooks
  readonly property alias defaultPolarity: adapter.defaultPolarity
  readonly property alias dateTimeFormat: adapter.dateTimeFormat

  property bool settled: false

  readonly property url wallpaper: {
    if (!settled) return "";

    const path = (adapter.wallpaper ?? "").trim();

    if (!path) return "";
    if (path.startsWith("file://")) return path;
    if (path.startsWith("~/")) return "file://" + Quickshell.env("HOME") + path.slice(1);
    if (path.startsWith("/")) return "file://" + path;

    return Qt.resolvedUrl("../" + path);
  }

  IpcHandler {
    target: "config"

    function reload(): void {
      view.reload();
    }
  }

  FileView {
    id: view

    path: Qt.resolvedUrl("../config.json")
    watchChanges: true
    onFileChanged: reload()

    onLoaded: root.settled = true
    onLoadFailed: root.settled = true

    JsonAdapter {
      id: adapter

      property JsonObject colors: JsonObject {
        property JsonObject dark: JsonObject {
          property string background: "#1d2021"
          property string surface: "#3c3836"
          property string on_surface: "#504945"
          property string foreground: "#d5c4a1"
          property string highlight: "#83a598"
          property string attention: "#fabd2f"
          property string ok: "#b8bb26"
          property string critical: "#fb4934"
        }

        property JsonObject light: JsonObject {
          property string background: "#fbf1c7"
          property string surface: "#ebdbb2"
          property string on_surface: "#d5c4a1"
          property string foreground: "#3c3836"
          property string highlight: "#076678"
          property string attention: "#b57614"
          property string ok: "#79740e"
          property string critical: "#9d0006"
        }
      }

      property JsonObject font: JsonObject {
        property string name: "JetBrainsMono Nerd Font"
        property int size: 12
      }

      property string wallpaper: "assets/sway.png"

      property string dateTimeFormat: "ddd d MMM HH:mm"

      property string defaultPolarity: "dark"

      property JsonObject hooks: JsonObject {
        property string onDarkThemeSet: ""
        property string onLightThemeSet: ""
      }

      property int spacing: 10

      property int border: 1
    }
  }
}

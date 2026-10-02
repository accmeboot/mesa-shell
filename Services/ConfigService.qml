pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  readonly property alias colors: adapter.colors
  readonly property QtObject font: QtObject {
    readonly property string name: {
      const name = (adapter.font.name ?? "").trim();
      return name || Qt.application.font.family;
    }
    readonly property real size: {
      const size = parseFloat((adapter.font.size ?? "").trim());
      if (isFinite(size) && size > 0) return size;

      const fallback = Qt.application.font.pointSize;
      return fallback > 0 ? fallback : 10;
    }
  }
  readonly property alias spacing: adapter.spacing
  readonly property alias border: adapter.border
  readonly property alias dateTimeFormat: adapter.dateTimeFormat

  readonly property int spaceSm: Math.round(root.spacing / 2)
  readonly property int spaceMd: root.spacing
  readonly property int spaceLg: root.spacing * 2
  readonly property int iconSize: Math.round(root.font.size * 1.5)
  readonly property int iconSizeSmall: Math.round(root.font.size * 1.2)
  readonly property int iconSizeLarge: Math.round(root.font.size * 2)
  readonly property int controlHeight: root.iconSize + root.spaceMd

  property bool settled: false

  readonly property alias wallpaper: adapter.wallpaper

  function toUrl(path: string): string {
    path = (path ?? "").trim();

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
          property string background: "#16181a"
          property string surface: "#26282a"
          property string on_surface: "#36383a"
          property string foreground: "#d6d9da"
          property string highlight: "#81adc7"
          property string attention: "#ead086"
          property string ok: "#8eba7a"
          property string critical: "#a94459"
        }

        property JsonObject light: JsonObject {
          property string background: "#faf8f3"
          property string surface: "#eae8e3"
          property string on_surface: "#dad8d3"
          property string foreground: "#393834"
          property string highlight: "#78b1ba"
          property string attention: "#ead086"
          property string ok: "#b3af62"
          property string critical: "#a94b27"
        }
      }

      property JsonObject font: JsonObject {
        property string name: ""
        property string size: ""
      }

      property JsonObject wallpaper: JsonObject {
        property string dark: "assets/hello-world.png"
        property string light: "assets/hello-world.png"
      }

      property string dateTimeFormat: "ddd d MMM HH:mm"

      property int spacing: 10

      property int border: 1
    }
  }
}

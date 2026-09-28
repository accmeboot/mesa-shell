pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property var outputs: ({})
  property var outputInfos: ({})
  property var layoutSymbols: []
  property int tagCount: 9

  readonly property string focusedOutput: Object.keys(root.outputs).find((name) => root.outputs[name].selmon) ?? ""
  readonly property string exitCommand: "kill \"$(dwlmsg -P)\""
  readonly property var layoutInfo: ({
    "[]=": { name: "Tile", icon: "layout-tile" },
    "><>": { name: "Floating", icon: "layout-floating" },
    "[M]": { name: "Monocle", icon: "layout-monocle" },
  })

  property var pending: ({})

  function hasTag(mask: int, tag: int): bool {
    return (mask & (1 << tag)) !== 0;
  }

  function tags(output: string): var {
    const state = root.outputs[output];
    if (!state) return [];

    return Array.from({ length: root.tagCount }, (_, tag) => ({
      index: tag,
      selected: root.hasTag(state.selected, tag),
      occupied: root.hasTag(state.occupied, tag),
      urgent: root.hasTag(state.urgent, tag),
      focusedClient: state.selmon && root.hasTag(state.focusedClient, tag),
    }));
  }

  function viewTag(output: string, tag: int): void {
    root.dwlmsg(["-o", output, "-s", "-t", String(tag)]);
  }

  function toggleTag(output: string, tag: int): void {
    root.dwlmsg(["-o", output, "-s", "-t", `${tag}^`]);
  }

  function workspaces(output: string): var {
    return root.tags(output).map((tag) => ({
      name: String(tag.index + 1),
      focused: tag.selected && output === root.focusedOutput,
      active: tag.selected,
      occupied: tag.occupied,
      holdsFocus: tag.focusedClient,
      monitor: output,
      number: tag.index + 1,
      urgent: tag.urgent,
      activate: () => root.viewTag(output, tag.index),
      toggle: () => root.toggleTag(output, tag.index),
    }));
  }

  function layoutIndex(output: string): int {
    return root.outputs[output]?.layoutIndex ?? -1;
  }

  function layouts(output: string): var {
    const current = root.layoutIndex(output);

    return root.layoutSymbols.map((symbol, index) => ({
      index: index,
      symbol: symbol,
      name: root.layoutInfo[symbol]?.name ?? symbol,
      icon: root.layoutInfo[symbol]?.icon ?? "layout-tile",
      current: index === current,
    }));
  }

  function setLayout(output: string, index: int): void {
    root.dwlmsg(["-o", output, "-s", "-l", String(index)]);
  }

  function outputInfo(output: string): var {
    return root.outputInfos[output] ?? null;
  }

  function refreshOutputs(): void {
    randr.running = true;
  }

  function dwlmsg(args: var): void {
    Quickshell.execDetached(["dwlmsg", ...args]);
  }

  function parse(line: string): void {
    const match = line.match(/^(\S+) (\S+) ?(.*)$/);
    if (!match) return;

    const [, output, key, value] = match;
    const state = root.pending[output] ?? (root.pending[output] = {});

    switch (key) {
    case "selmon":
      state.selmon = value === "1";
      break;
    case "layout_index":
      state.layoutIndex = parseInt(value, 10);
      break;
    case "tag": {
      const [tag, tagState, clients, focused] = value.split(" ").map((n) => parseInt(n, 10));
      const bit = 1 << tag;

      if (tagState & 1) state.selected = (state.selected ?? 0) | bit;
      if (tagState & 2) state.urgent = (state.urgent ?? 0) | bit;
      if (clients > 0) state.occupied = (state.occupied ?? 0) | bit;
      if (focused) state.focusedClient = (state.focusedClient ?? 0) | bit;
      break;
    }
    case "tags":
      root.commit(output);
      break;
    }
  }

  function commit(output: string): void {
    const state = root.pending[output];
    const next = {};

    for (const name in root.outputs) {
      next[name] = state.selmon && name !== output ? Object.assign({}, root.outputs[name], { selmon: false }) : root.outputs[name];
    }

    next[output] = Object.assign({ selected: 0, urgent: 0, occupied: 0, focusedClient: 0 }, state);
    root.outputs = next;

    root.pending[output] = { selmon: state.selmon, layoutIndex: state.layoutIndex };
  }

  Process {
    id: watch

    command: ["dwlmsg", "-w"]
    running: true

    stdout: SplitParser {
      onRead: (line) => root.parse(line)
    }

    onExited: restart.start()
  }

  Timer {
    id: restart

    interval: 1000
    onTriggered: watch.running = true
  }

  Process {
    command: ["dwlmsg", "-T"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        const count = parseInt(this.text, 10);
        if (count > 0) root.tagCount = count;
      }
    }
  }

  Process {
    command: ["dwlmsg", "-L"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: root.layoutSymbols = this.text.split("\n").filter((l) => l !== "")
    }
  }

  Process {
    id: randr

    command: ["wlr-randr", "--json"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const infos = {};

          for (const output of JSON.parse(this.text)) {
            const mode = output.modes?.find((m) => m.current) ?? null;

            infos[output.name] = {
              name: output.name,
              make: output.make ?? "",
              model: output.model ?? "",
              serial: output.serial ?? "",
              width: mode?.width ?? 0,
              height: mode?.height ?? 0,
              refresh: mode?.refresh ?? 0,
              scale: output.scale ?? 0,
              transform: output.transform ?? "",
              adaptiveSync: output.adaptive_sync === undefined ? "" : output.adaptive_sync ? "enabled" : "disabled",
            };
          }

          root.outputInfos = infos;
        } catch (e) {
          console.error(e);
        }
      }
    }
  }

  Connections {
    target: Quickshell

    function onScreensChanged(): void {
      root.refreshOutputs();
    }
  }
}

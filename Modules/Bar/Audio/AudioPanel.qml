import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import qs.Services
import qs.Components

Item {
  id: root

  readonly property var nodes: Pipewire.nodes.values.filter(node => node.audio)

  readonly property var sinks: root.nodes.filter(node => node.isSink && !node.isStream)
  readonly property var sources: root.nodes.filter(node => !node.isSink && !node.isStream)
  readonly property var playbacks: root.nodes.filter(node => node.isStream && node.isSink && !root.isMonitor(node))
  readonly property var recordings: root.nodes.filter(node => node.isStream && !node.isSink && !root.isMonitor(node))

  property var openRow: null

  function isMonitor(node: PwNode): bool {
    const monitor = node.properties["stream.monitor"];
    return monitor === true || monitor === "true";
  }

  function toggle(row: var): void {
    root.openRow = root.openRow === row ? null : row;
  }

  implicitHeight: column.implicitHeight

  PwObjectTracker {
    objects: root.nodes
  }

  ColumnLayout {
    id: column

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top

    spacing: ConfigService.spacing * 2

    MesaSection {
      title: "Output"

      visible: root.sinks.length > 0

      AudioDeviceRow {
        id: outputRow

        nodes: root.sinks
        defaultNode: Pipewire.defaultAudioSink
        expanded: root.openRow === outputRow

        onToggled: root.toggle(outputRow)
        onNodeSelected: node => Pipewire.preferredDefaultAudioSink = node
      }
    }

    MesaSection {
      title: "Input"

      visible: root.sources.length > 0

      AudioDeviceRow {
        id: inputRow

        nodes: root.sources
        defaultNode: Pipewire.defaultAudioSource
        expanded: root.openRow === inputRow

        icon: "audio-input-microphone-high"
        mutedIcon: "audio-input-microphone-muted"

        onToggled: root.toggle(inputRow)
        onNodeSelected: node => Pipewire.preferredDefaultAudioSource = node
      }
    }

    AudioNodeGroup {
      title: "Playback"

      nodes: root.playbacks
    }

    AudioNodeGroup {
      title: "Recording"

      nodes: root.recordings

      icon: "audio-input-microphone-high"
      mutedIcon: "audio-input-microphone-muted"
    }
  }

  MouseArea {
    anchors.fill: parent

    visible: root.openRow !== null
    acceptedButtons: Qt.AllButtons

    onClicked: root.openRow = null
  }

  Loader {
    id: listLoader

    active: root.openRow !== null

    readonly property int anchorTop: root.openRow ? root.openRow.select.mapToItem(root, 0, 0).y : 0
    readonly property int anchorBottom: root.openRow ? root.openRow.select.mapToItem(root, 0, root.openRow.select.height).y : 0
    readonly property int spaceBelow: root.height - listLoader.anchorBottom + ConfigService.border
    readonly property int spaceAbove: listLoader.anchorTop + ConfigService.border
    readonly property bool flipped: listLoader.spaceBelow < (listLoader.item?.fullHeight ?? 0) && listLoader.spaceAbove > listLoader.spaceBelow

    x: {
      if (!root.openRow) return 0;

      const origin = root.openRow.select.mapToItem(root, 0, 0);
      const limit = root.width - listLoader.width - ConfigService.spacing;

      return Math.max(ConfigService.spacing, Math.min(origin.x, limit));
    }

    y: {
      const target = listLoader.flipped
      ? listLoader.anchorTop - listLoader.height + ConfigService.border
      : listLoader.anchorBottom - ConfigService.border;

      return Math.max(0, Math.min(target, root.height - listLoader.height));
    }

    width: {
      if (!root.openRow) return 0;

      const content = listLoader.item?.implicitWidth ?? 0;

      return Math.min(Math.max(root.openRow.select.width, content), root.width - ConfigService.spacing * 2);
    }

    height: listLoader.item?.implicitHeight ?? 0

    sourceComponent: MesaSelectList {
      options: root.openRow?.options ?? []
      maximumHeight: listLoader.flipped ? listLoader.spaceAbove : listLoader.spaceBelow

      onSelected: value => {
        root.openRow.nodeSelected(value);
        root.openRow = null;
      }
    }
  }
}

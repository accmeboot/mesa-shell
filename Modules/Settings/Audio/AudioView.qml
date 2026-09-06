import QtQuick.Layouts
import Quickshell.Services.Pipewire

import qs.Services
import qs.Modules.Settings.Common

ColumnLayout {
  id: root

  readonly property var nodes: Pipewire.nodes.values.filter(node => node.audio)

  readonly property var sinks: root.nodes.filter(node => node.isSink && !node.isStream)
  readonly property var sources: root.nodes.filter(node => !node.isSink && !node.isStream)
  readonly property var playbacks: root.nodes.filter(node => node.isStream && node.isSink && !root.isMonitor(node))
  readonly property var recordings: root.nodes.filter(node => node.isStream && !node.isSink && !root.isMonitor(node))

  function isMonitor(node: PwNode): bool {
    const monitor = node.properties["stream.monitor"];
    return monitor === true || monitor === "true";
  }

  spacing: ConfigService.spacing

  PwObjectTracker {
    objects: root.nodes
  }

  AudioNodeGroup {
    title: "Output"

    nodes: root.sinks
    defaultNode: Pipewire.defaultAudioSink

    onNodeActivated: node => Pipewire.preferredDefaultAudioSink = node
  }

  AudioNodeGroup {
    title: "Input"

    nodes: root.sources
    defaultNode: Pipewire.defaultAudioSource

    icon: "microphone"
    mutedIcon: "microphone-off"

    onNodeActivated: node => Pipewire.preferredDefaultAudioSource = node
  }

  AudioNodeGroup {
    title: "Playback"

    nodes: root.playbacks
    selectable: false
  }

  AudioNodeGroup {
    title: "Recording"

    nodes: root.recordings
    selectable: false

    icon: "microphone"
    mutedIcon: "microphone-off"
  }
}

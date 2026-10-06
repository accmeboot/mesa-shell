import Quickshell.Services.Pipewire

import qs.Components

MesaPanel {
  id: root

  required property bool output

  readonly property var nodes: Pipewire.nodes.values.filter(node => node.audio && node.isSink === root.output)

  readonly property var devices: root.nodes.filter(node => !node.isStream)
  readonly property var streams: root.nodes.filter(node => node.isStream && !root.isMonitor(node))

  function isMonitor(node: PwNode): bool {
    const monitor = node.properties["stream.monitor"];
    return monitor === true || monitor === "true";
  }

  PwObjectTracker {
    objects: root.nodes
  }

  AudioDeviceGroup {
    nodes: root.devices
    defaultNode: root.output ? Pipewire.defaultAudioSink : Pipewire.defaultAudioSource

    onNodeSelected: node => {
      if (root.output) Pipewire.preferredDefaultAudioSink = node;
      else Pipewire.preferredDefaultAudioSource = node;
    }
  }

  AudioNodeGroup {
    nodes: root.streams
  }
}

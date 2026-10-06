import Quickshell.Services.Pipewire

import qs.Components

MesaPanelWidget {
  id: root

  required property bool output

  readonly property PwNode node: root.output ? Pipewire.defaultAudioSink : Pipewire.defaultAudioSource
  readonly property bool muted: root.node?.audio?.muted ?? true

  panel: root.output ? "audio" : "microphone"
  icon: {
    if (root.output) return root.muted ? "audio-volume-muted" : "audio-volume-high";

    return root.muted ? "audio-input-microphone-muted" : "audio-input-microphone-high";
  }

  content: AudioPanel {
    output: root.output
  }

  PwObjectTracker {
    objects: root.node ? [root.node] : []
  }
}

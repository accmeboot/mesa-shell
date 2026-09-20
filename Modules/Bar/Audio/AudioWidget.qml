import Quickshell.Services.Pipewire

import qs.Components

MesaPanelWidget {
  id: root

  readonly property PwNode sink: Pipewire.defaultAudioSink

  panel: "audio"
  icon: (root.sink?.audio?.muted ?? true) ? "audio-volume-muted" : "audio-volume-high"

  content: AudioPanel {}

  PwObjectTracker {
    objects: root.sink ? [root.sink] : []
  }
}

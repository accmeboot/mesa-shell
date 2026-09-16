import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

RowLayout {
  id: root

  required property var screen

  property bool isOpen: false

  readonly property PwNode sink: Pipewire.defaultAudioSink

  readonly property string icon: (root.sink?.audio?.muted ?? true) ? "audio-volume-muted" : "audio-volume-high"

  spacing: 0

  PwObjectTracker {
    objects: root.sink ? [root.sink] : []
  }

  MesaButton {
    id: button

    Layout.fillHeight: true

    icon: root.icon

    onClicked: root.isOpen = !root.isOpen
 }

  MesaPopup {
    open: root.isOpen
    screen: root.screen
    exclude: root
    namespace: "mesa-audio"

    content: AudioPanel {}

    onDismissed: root.isOpen = false
  }
}

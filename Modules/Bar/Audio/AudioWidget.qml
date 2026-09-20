import Quickshell.Services.Pipewire
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

RowLayout {
  id: root

  required property var screen
  required property int popupWidth

  readonly property bool isOpen: PanelService.current === "audio" && PanelService.screen === root.screen.name

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

    onClicked: PanelService.toggle("audio", root.screen.name)
 }

  MesaPopup {
    open: root.isOpen
    screen: root.screen
    width: root.popupWidth
    exclude: root
    namespace: "mesa-audio"
    keyboardFocus: WlrKeyboardFocus.Exclusive

    content: AudioPanel {}

    onDismissed: PanelService.close("audio")
  }
}

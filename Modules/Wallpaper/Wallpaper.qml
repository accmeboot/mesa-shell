import Quickshell
import QtQuick
import Quickshell.Wayland

import qs.Services

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData

      screen: modelData

      color: ConfigService.colors.background

      WlrLayershell.layer: WlrLayer.Background
      WlrLayershell.namespace: "mesa-wallpaper"
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

      exclusionMode: ExclusionMode.Ignore

      mask: Region {}

      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }

      Image {
        anchors.fill: parent

        source: ConfigService.wallpaper
        fillMode: Image.PreserveAspectCrop
        asynchronous: true

        retainWhileLoading: true

        sourceSize.width: Math.round(width * modelData.devicePixelRatio)
        sourceSize.height: Math.round(height * modelData.devicePixelRatio)
      }
    }
  }
}

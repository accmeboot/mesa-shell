import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.Services

Scope {
  id: root

  property bool active: false
  property int layer: WlrLayer.Top
  property string namespace: "mesa-catcher"
  property Item exclude: null
  property var excludeScreen: null

  signal dismissed()

  onActiveChanged: if (root.active) CatcherService.current = root.namespace

  Connections {
    target: CatcherService

    function onCurrentChanged(): void {
      if (root.active && CatcherService.current !== root.namespace) root.dismissed();
    }
  }

  LazyLoader {
    active: root.active

    Variants {
      model: Quickshell.screens

      PanelWindow {
        id: catcher

        required property var modelData

        screen: modelData
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.layer: root.layer
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: root.namespace

        anchors {
          top: true
          bottom: true
          left: true
          right: true
        }

        mask: Region {
          item: catcher.modelData === root.excludeScreen ? root.exclude : null
          intersection: Intersection.Subtract
        }

        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.AllButtons

          onClicked: root.dismissed()
        }
      }
    }
  }
}

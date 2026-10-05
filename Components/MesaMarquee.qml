import QtQuick

import qs.Services

Item {
  id: root

  property alias text: label.text
  property alias color: label.color
  property alias textFormat: label.textFormat
  property bool running: false
  property real speed: ConfigService.font.size * 3
  property int delay: 500
  property int pause: 1000

  property int offset: 0

  readonly property int overflow: Math.max(0, Math.ceil(label.implicitWidth) - Math.floor(root.width))
  readonly property bool sliding: root.running && root.overflow > 0

  implicitWidth: label.implicitWidth
  implicitHeight: label.implicitHeight
  clip: root.sliding

  onOverflowChanged: if (slide.running) slide.restart()

  MesaText {
    id: label

    anchors.verticalCenter: parent.verticalCenter

    x: -root.offset
    width: root.sliding ? label.implicitWidth : root.width
    elide: root.sliding ? Text.ElideNone : Text.ElideRight
  }

  SequentialAnimation {
    id: slide

    running: root.sliding
    loops: Animation.Infinite

    onRunningChanged: if (!slide.running) root.offset = 0

    PauseAnimation {
      duration: root.delay
    }

    NumberAnimation {
      target: root
      property: "offset"
      from: 0
      to: root.overflow
      duration: root.overflow * 1000 / root.speed
    }

    PauseAnimation {
      duration: root.pause
    }

    NumberAnimation {
      target: root
      property: "offset"
      from: root.overflow
      to: 0
      duration: root.overflow * 1000 / root.speed
    }
  }
}

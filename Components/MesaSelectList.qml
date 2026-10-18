import QtQuick

import qs.Services

MesaSurface {
  id: root

  property var options: []
  property int currentIndex: -1
  property int maximumRows: 4
  property bool bottomUp: false

  readonly property int rowHeight: ConfigService.controlHeight

  signal selected(var value)
  signal stepped(int delta)

  function ensureVisible(): void {
    if (root.currentIndex >= 0) list.positionViewAtIndex(root.currentIndex, ListView.Contain);
  }

  onCurrentIndexChanged: root.ensureVisible()
  onOptionsChanged: Qt.callLater(root.ensureVisible)

  implicitWidth: {
    let widest = 0;

    for (const option of root.options) {
      widest = Math.max(widest, metrics.advanceWidth(option.text));
    }

    return Math.min(ConfigService.panelMaxWidth, Math.ceil(widest) + ConfigService.space * 2 + root.padding * 2);
  }
  implicitHeight: Math.min(root.options.length, root.maximumRows) * root.rowHeight + root.padding * 2

  FontMetrics {
    id: metrics

    font.family: ConfigService.font.name
    font.pointSize: ConfigService.font.size
  }

  contentItem: ListView {
    id: list

    model: root.options
    verticalLayoutDirection: root.bottomUp ? ListView.BottomToTop : ListView.TopToBottom
    clip: true
    interactive: false

    delegate: Rectangle {
      id: option

      required property var modelData
      required property int index

      readonly property bool highlighted: option.index === root.currentIndex

      width: list.width
      height: root.rowHeight
      color: option.highlighted ? ThemeService.selection : ThemeService.colors.background
      radius: ConfigService.radius

      MouseArea {
        anchors.fill: parent

        onClicked: root.selected(option.modelData.value)
      }

      MesaMarquee {
        anchors.fill: parent
        anchors.leftMargin: ConfigService.space
        anchors.rightMargin: ConfigService.space

        text: option.modelData.text
        running: option.highlighted
      }
    }
  }

  MouseArea {
    id: wheelArea

    anchors.fill: list

    acceptedButtons: Qt.NoButton
    cursorShape: Qt.PointingHandCursor

    property int notches: 0

    onWheel: wheel => {
      const delta = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.angleDelta.x;

      wheelArea.notches += root.bottomUp ? -delta : delta;

      while (wheelArea.notches <= -120) {
        wheelArea.notches += 120;
        root.stepped(1);
      }

      while (wheelArea.notches >= 120) {
        wheelArea.notches -= 120;
        root.stepped(-1);
      }
    }
  }
}

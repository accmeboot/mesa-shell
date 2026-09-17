import QtQuick

import qs.Services

Rectangle {
  id: root

  property var options: []
  property int currentIndex: -1
  property int maximumRows: 4

  readonly property int contentMargin: ConfigService.gap
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

    return Math.ceil(widest) + root.contentMargin * 2 + root.border.width * 2;
  }
  implicitHeight: Math.min(root.options.length, root.maximumRows) * root.rowHeight + root.border.width * 2

  color: ThemeService.colors.background

  border.color: ThemeService.colors.on_surface
  border.width: ConfigService.border

  FontMetrics {
    id: metrics

    font.family: ConfigService.font.name
    font.pointSize: ConfigService.font.size
  }

  ListView {
    id: list

    anchors.fill: parent
    anchors.margins: root.border.width

    model: root.options
    clip: true
    interactive: false

    delegate: Rectangle {
      id: option

      required property var modelData
      required property int index

      readonly property bool highlighted: option.index === root.currentIndex

      width: list.width
      height: root.rowHeight
      color: option.highlighted ? ThemeService.colors.highlight : ThemeService.colors.background

      MouseArea {
        anchors.fill: parent

        onClicked: root.selected(option.modelData.value)
      }

      MesaText {
        anchors.fill: parent
        anchors.leftMargin: root.contentMargin - root.border.width
        anchors.rightMargin: root.contentMargin - root.border.width

        text: option.modelData.text
        color: option.highlighted ? ThemeService.colors.background : ThemeService.colors.foreground
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
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
      wheelArea.notches += wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.angleDelta.x;

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

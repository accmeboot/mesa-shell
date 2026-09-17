import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.Services

Rectangle {
  id: root

  property var options: []
  property int currentIndex: -1
  property int maximumRows: 4
  property int maximumHeight: 0
  property bool showScrollBar: true
  property bool wheelSelects: false
  property bool hoverHighlight: true

  readonly property int iconSize: ConfigService.iconSize
  readonly property int contentMargin: ConfigService.gap
  readonly property int rowSpacing: ConfigService.gapSmall
  readonly property int rowHeight: root.iconSize + ConfigService.gap
  readonly property bool hasIcons: root.options.some(option => (option.icon ?? "") !== "")
  readonly property bool scrollable: root.options.length > root.visibleRows
  readonly property int scrollWidth: Math.max(ConfigService.border, Math.round(ConfigService.font.size / 3))
  readonly property int scrollGutter: root.scrollable && root.showScrollBar ? root.scrollWidth + root.contentMargin : 0
  readonly property int rows: Math.min(root.options.length, root.maximumRows)
  readonly property int fullHeight: root.rows * root.rowHeight + root.border.width * 2
  readonly property int visibleRows: {
    if (root.maximumHeight <= 0) return root.rows;

    const fits = Math.floor((root.maximumHeight - root.border.width * 2) / root.rowHeight);

    return Math.max(1, Math.min(root.rows, fits));
  }

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

    const icons = root.hasIcons ? root.iconSize + root.rowSpacing : 0;

    return Math.ceil(widest) + icons + root.scrollGutter + root.contentMargin * 2 + root.border.width * 2;
  }
  implicitHeight: root.visibleRows * root.rowHeight + root.border.width * 2

  color: ThemeService.colors.background

  border.color: ThemeService.colors.on_surface
  border.width: ConfigService.border

  MouseArea {
    anchors.fill: parent

    acceptedButtons: Qt.AllButtons
  }

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
    interactive: !root.wheelSelects
    boundsBehavior: Flickable.StopAtBounds

    ScrollBar.vertical: ScrollBar {
      id: scroll

      policy: root.scrollable && root.showScrollBar ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

      contentItem: Rectangle {
        implicitWidth: root.scrollWidth
        color: ThemeService.colors.foreground
      }

      background: Rectangle {
        implicitWidth: root.scrollWidth
        color: ThemeService.colors.on_surface
      }
    }

    delegate: Rectangle {
      id: option

      required property var modelData
      required property int index

      readonly property bool highlighted: option.index === root.currentIndex || (root.hoverHighlight && rowArea.containsMouse)

      width: list.width - root.scrollGutter
      height: root.rowHeight
      color: option.highlighted ? ThemeService.colors.highlight : ThemeService.colors.background

      MouseArea {
        id: rowArea

        anchors.fill: parent

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.selected(option.modelData.value)
      }

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: root.contentMargin - root.border.width
        anchors.rightMargin: root.contentMargin - root.border.width

        spacing: root.rowSpacing

        MesaIcon {
          Layout.alignment: Qt.AlignVCenter

          visible: (option.modelData.icon ?? "") !== ""
          name: option.modelData.icon ?? ""
          size: root.iconSize
          color: option.highlighted ? ThemeService.colors.background : ThemeService.colors.foreground
        }

        MesaText {
          Layout.fillWidth: true

          text: option.modelData.text
          color: option.highlighted ? ThemeService.colors.background : ThemeService.colors.foreground
          elide: Text.ElideRight
        }
      }
    }
  }

  MouseArea {
    id: wheelArea

    anchors.fill: list

    acceptedButtons: Qt.NoButton

    property int notches: 0

    onWheel: wheel => {
      const delta = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.angleDelta.x;

      if (root.wheelSelects) {
        wheelArea.notches += delta;

        while (wheelArea.notches <= -120) {
          wheelArea.notches += 120;
          root.stepped(1);
        }

        while (wheelArea.notches >= 120) {
          wheelArea.notches -= 120;
          root.stepped(-1);
        }

        return;
      }

      const limit = Math.max(0, list.contentHeight - list.height);

      list.contentY = Math.max(0, Math.min(limit, list.contentY - delta));
    }
  }
}

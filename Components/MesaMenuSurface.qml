import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

import qs.Services

PopupWindow {
  id: root

  property var entries: []
  property Item anchorItem: null
  property bool submenu: false
  property bool active: false
  property int currentIndex: -1

  readonly property var list: root.entries ?? []
  readonly property bool shouldShow: root.active && root.list.length > 0

  readonly property real sliderStep: 0.01

  readonly property int rowPadding: ConfigService.spaceMd
  readonly property int indicatorSize: ConfigService.iconSize
  readonly property bool hasIndicators: root.list.some(entry => entry.icon !== "" || entry.buttonType !== QsMenuButtonType.None)
  readonly property bool hasToggles: root.list.some(entry => entry.buttonType === QsMenuButtonType.CheckBox)
  readonly property int indicatorWidth: root.hasToggles ? Math.max(root.indicatorSize, toggleMetrics.implicitWidth) : root.indicatorSize

  signal triggered(int index)
  signal submenuRequested(int index)
  signal entered(int index)
  signal backerHidden()

  function entryAt(index: int): var {
    return root.list[index] ?? null;
  }

  function rowAt(index: int): Item {
    return rows.itemAt(index);
  }

  function selectFirst(): void {
    root.currentIndex = -1;
    root.step(1);
  }

  function step(delta: int): void {
    const entries = root.list;

    if (entries.length === 0) return;

    let index = root.currentIndex < 0 ? (delta > 0 ? -1 : 0) : root.currentIndex;

    for (let i = 0; i < entries.length; i++) {
      index = (index + delta + entries.length) % entries.length;

      const entry = entries[index];

      if (entry.isSeparator || !entry.enabled) continue;

      root.currentIndex = index;
      return;
    }
  }

  function activate(): void {
    const entry = root.entryAt(root.currentIndex);

    if (!entry || entry.isSeparator || !entry.enabled) return;

    if (entry.slider) return;

    if (entry.hasChildren) {
      root.submenuRequested(root.currentIndex);
      return;
    }

    root.triggered(root.currentIndex);
  }

  function adjust(delta: int): void {
    const entry = root.entryAt(root.currentIndex);

    if (!entry || !entry.slider || !entry.enabled) return;

    const next = Math.max(0, Math.min(1, entry.value + delta * root.sliderStep));

    if (next !== entry.value) entry.adjusted(next);
  }

  visible: root.shouldShow
  color: "transparent"
  anchor.item: root.anchorItem
  anchor.edges: root.submenu ? Edges.Right | Edges.Top : Edges.Bottom | Edges.Left
  anchor.gravity: root.submenu ? Edges.Right | Edges.Bottom : Edges.Bottom | Edges.Right
  anchor.adjustment: PopupAdjustment.Flip | PopupAdjustment.Slide
  implicitWidth: background.implicitWidth
  implicitHeight: background.implicitHeight

  onBackerVisibilityChanged: if (!root.backingWindowVisible && root.shouldShow) root.backerHidden()

  MesaIndicator {
    id: toggleMetrics

    visible: false
  }

  TextMetrics {
    id: valueMetrics

    font.family: ConfigService.font.name
    font.pointSize: ConfigService.font.size
    text: "100%"
  }

  Rectangle {
    id: background

    anchors.fill: parent
    implicitWidth: entries.implicitWidth + border.width * 2
    implicitHeight: entries.implicitHeight + border.width * 2
    color: ThemeService.colors.background
    border.width: ConfigService.border
    border.color: ThemeService.colors.on_surface

    ColumnLayout {
      id: entries

      anchors.fill: parent
      anchors.margins: background.border.width
      spacing: 0

      Repeater {
        id: rows

        model: root.list

        Rectangle {
          id: row

          required property var modelData
          required property int index

          readonly property bool highlighted: row.index === root.currentIndex
          readonly property bool isSlider: row.modelData.slider ?? false
          readonly property color contentColor: row.foreground
          readonly property color surfaceColor: row.color
          readonly property color foreground: {
            if (!row.modelData.enabled) return ThemeService.colors.on_surface;

            return row.highlighted ? ThemeService.colors.background : ThemeService.colors.foreground;
          }

          Layout.fillWidth: true
          implicitWidth: row.modelData.isSeparator ? 0 : content.implicitWidth + root.rowPadding * 2
          implicitHeight: row.modelData.isSeparator ? ConfigService.border : Math.max(content.implicitHeight, ConfigService.controlHeight)
          color: {
            if (row.modelData.isSeparator) return ThemeService.colors.on_surface;

            return row.highlighted ? ThemeService.colors.highlight : ThemeService.colors.background;
          }

          RowLayout {
            id: content

            visible: !row.modelData.isSeparator
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: root.rowPadding
            anchors.rightMargin: root.rowPadding
            spacing: ConfigService.spaceMd

            Item {
              visible: root.hasIndicators
              Layout.preferredWidth: root.indicatorWidth
              Layout.preferredHeight: root.indicatorSize

              MesaIndicator {
                id: indicator

                anchors.centerIn: parent
                enabled: row.modelData.enabled
                visible: row.modelData.buttonType !== QsMenuButtonType.None
                checked: row.modelData.checkState === Qt.Checked
                radio: row.modelData.buttonType === QsMenuButtonType.RadioButton
                color: row.foreground
                backgroundColor: row.color
              }

              IconImage {
                anchors.centerIn: parent
                visible: !indicator.visible && row.modelData.icon !== ""
                implicitSize: root.indicatorSize
                source: row.modelData.icon
              }
            }

            MesaText {
              Layout.fillWidth: !row.isSlider
              text: row.modelData.text
              color: row.foreground
            }

            MesaSlider {
              Layout.fillWidth: true
              Layout.alignment: Qt.AlignVCenter

              visible: row.isSlider
              enabled: row.modelData.enabled
              value: row.modelData.value

              onMoved: row.modelData.adjusted(value)
            }

            MesaText {
              Layout.preferredWidth: Math.ceil(valueMetrics.advanceWidth)

              visible: row.isSlider
              text: `${Math.round(row.modelData.value * 100)}%`
              color: row.foreground
              horizontalAlignment: Text.AlignRight
            }

            MesaIcon {
              visible: row.modelData.hasChildren
              name: "pan-end"
              size: root.indicatorSize
              color: row.foreground
            }
          }

          MouseArea {
            anchors.fill: parent
            enabled: !row.modelData.isSeparator && row.modelData.enabled
            acceptedButtons: row.isSlider ? Qt.NoButton : Qt.LeftButton
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onEntered: root.entered(row.index)
            onClicked: {
              root.currentIndex = row.index;
              root.activate();
            }
          }
        }
      }
    }
  }
}

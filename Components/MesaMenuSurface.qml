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

  readonly property int near: ConfigService.bottom ? Edges.Bottom : Edges.Top
  readonly property int far: ConfigService.bottom ? Edges.Top : Edges.Bottom

  readonly property int indicatorSize: ConfigService.iconSize
  readonly property bool hasIndicators: root.list.some(entry => (entry.icon !== "" && entry.text === "") || entry.buttonType !== QsMenuButtonType.None)
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

    if (entry.isInput && entry.text === "") return;

    if (entry.hasChildren) {
      root.submenuRequested(root.currentIndex);
      return;
    }

    root.triggered(root.currentIndex);
  }

  function type(event: var): bool {
    const entry = root.entryAt(root.currentIndex);

    if (!entry || !entry.isInput || !entry.enabled) return false;

    if (event.key === Qt.Key_Backspace) {
      entry.text = event.modifiers & Qt.ControlModifier ? "" : entry.text.slice(0, -1);
      return true;
    }

    if (event.key === Qt.Key_U && event.modifiers & Qt.ControlModifier) {
      entry.text = "";
      return true;
    }

    if (event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier)) return false;

    const code = event.text.length > 0 ? event.text.charCodeAt(0) : 0;

    if (code < 32 || code === 127) return false;

    entry.text += event.text;
    return true;
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
  anchor.edges: root.submenu ? Edges.Right | root.near : root.far | Edges.Left
  anchor.gravity: root.submenu ? Edges.Right | root.far : root.far | Edges.Right
  anchor.adjustment: PopupAdjustment.Flip | PopupAdjustment.Slide
  anchor.margins.top: root.submenu ? (ConfigService.bottom ? 0 : -ConfigService.popupInset) : (ConfigService.bottom ? -ConfigService.barPadding : 0)
  anchor.margins.bottom: root.submenu ? (ConfigService.bottom ? -ConfigService.popupInset : 0) : (ConfigService.bottom ? 0 : -ConfigService.barPadding)
  anchor.margins.left: root.submenu ? -ConfigService.popupPadding : 0
  anchor.margins.right: root.submenu ? -ConfigService.popupPadding : 0
  implicitWidth: background.implicitWidth
  implicitHeight: background.implicitHeight

  onBackerVisibilityChanged: if (!root.backingWindowVisible && root.shouldShow) root.backerHidden()

  MesaIndicator {
    id: toggleMetrics

    visible: false
  }

  TextMetrics {
    id: inputMetrics

    font.family: ConfigService.font.name
    font.pointSize: ConfigService.font.size
    text: "0".repeat(20)
  }

  TextMetrics {
    id: valueMetrics

    font.family: ConfigService.font.name
    font.pointSize: ConfigService.font.size
    text: "100%"
  }

  MesaSurface {
    id: background

    anchors.fill: parent
    implicitWidth: Math.min(ConfigService.panelMaxWidth, background.implicitContentWidth + background.padding * 2)

    contentItem: ColumnLayout {
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
          readonly property bool isInput: row.modelData.isInput ?? false
          readonly property real value: row.modelData.value ?? 0
          readonly property color surfaceColor: row.color
          readonly property color foreground: row.modelData.enabled ? ThemeService.colors.foreground : ThemeService.disabled

          Layout.fillWidth: true
          implicitWidth: {
            if (row.modelData.isSeparator) return 0;

            return content.implicitWidth + ConfigService.space * 2;
          }
          implicitHeight: {
            if (row.modelData.isSeparator) return separator.implicitHeight;

            return Math.max(content.implicitHeight, ConfigService.controlHeight);
          }
          color: {
            if (row.modelData.isSeparator) return "transparent";
            return row.highlighted ? ThemeService.selection : ThemeService.colors.background;
          }
          radius: ConfigService.radius

          MesaSeparator {
            id: separator

            visible: row.modelData.isSeparator
            width: parent.width
          }

          RowLayout {
            id: content

            visible: !row.modelData.isSeparator
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: ConfigService.space
            anchors.rightMargin: ConfigService.space
            spacing: ConfigService.space

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
                visible: !indicator.visible && row.modelData.icon !== "" && row.modelData.text === ""
                implicitSize: root.indicatorSize
                source: row.modelData.icon
              }
            }

            MesaMarquee {
              Layout.fillWidth: !row.isSlider

              visible: !row.isInput
              text: row.modelData.text
              color: row.foreground
              running: row.highlighted
            }

            Item {
              Layout.fillWidth: true
              Layout.preferredWidth: Math.ceil(inputMetrics.advanceWidth)
              Layout.preferredHeight: inputText.implicitHeight

              visible: row.isInput

              MesaText {
                id: inputText

                readonly property bool empty: row.modelData.text === ""

                width: Math.min(inputText.implicitWidth, parent.width - caret.width)
                text: {
                  if (inputText.empty) return row.modelData.placeholder ?? "";

                  return row.modelData.secret ? "*".repeat(row.modelData.text.length) : row.modelData.text;
                }
                color: inputText.empty ? Qt.alpha(row.foreground, 0.6) : row.foreground
                elide: Text.ElideLeft
              }

              Rectangle {
                id: caret

                x: inputText.empty ? 0 : inputText.width
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(ConfigService.border, Math.round(ConfigService.font.size * 0.15))
                height: inputText.implicitHeight
                visible: row.highlighted && caretBlink.shown
                color: row.foreground
              }

              Timer {
                id: caretBlink

                property bool shown: true

                interval: 530
                repeat: true
                running: row.isInput && row.highlighted

                onRunningChanged: caretBlink.shown = true
                onTriggered: caretBlink.shown = !caretBlink.shown
              }
            }

            MesaSlider {
              Layout.fillWidth: true
              Layout.alignment: Qt.AlignVCenter

              visible: row.isSlider
              enabled: row.modelData.enabled
              value: row.value

              onMoved: row.modelData.adjusted(value)
            }

            MesaText {
              Layout.preferredWidth: Math.ceil(valueMetrics.advanceWidth)

              visible: row.isSlider
              text: `${Math.round(row.value * 100)}%`
              color: row.foreground
              horizontalAlignment: Text.AlignRight
            }

            MesaChevron {
              visible: row.modelData.hasChildren
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

              if (row.isInput) return;

              root.activate();
            }
          }
        }
      }
    }
  }
}

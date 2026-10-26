import QtQuick
import QtQuick.Layouts
import QtQuick.Window

import qs.Services

Rectangle {
  id: root

  property string label
  property string sublabel
  property string value
  property Component leading: null
  property MesaRowMenu menu: null
  property bool interactive: false
  property bool wideTrailing: false

  default property alias trailing: content.data

  readonly property bool containsFocus: {
    for (let item = root.Window.activeFocusItem; item; item = item.parent) {
      if (item === root) return true;
    }

    return false;
  }

  readonly property bool highlighted: root.containsFocus
  readonly property color surfaceColor: root.highlighted ? ThemeService.colors.highlight : ThemeService.colors.background
  readonly property color foreground: root.highlighted ? ThemeService.colors.background : ThemeService.colors.foreground
  readonly property color muted: Qt.alpha(root.foreground, 0.6)

  readonly property int leadingSize: Math.round(ConfigService.font.size * 0.5)
  readonly property point labelPosition: Qt.point(
    content.x + labels.x + labelText.x + labelMetrics.tightBoundingRect.x,
    content.y + labels.y + labelText.y + labelText.baselineOffset + labelMetrics.tightBoundingRect.y
  )

  signal clicked()

  Layout.fillWidth: true

  implicitWidth: content.implicitWidth + ConfigService.space * 2
  implicitHeight: Math.max(content.implicitHeight, ConfigService.controlHeight)
  color: root.highlighted ? root.surfaceColor : "transparent"

  activeFocusOnTab: root.interactive

  function openMenu(): void {
    if (!root.menu) return;

    root.menu.showAt(root);
  }

  function press(): void {
    if (root.menu) {
      root.menu.toggleAt(root);
      return;
    }

    root.clicked();
  }

  function trigger(): void {
    if (MenuService.isOpen) {
      MenuService.current.activate();
      return;
    }

    if (root.menu) {
      root.openMenu();
      return;
    }

    root.clicked();
  }

  onActiveFocusChanged: {
    if (!root.activeFocus || !MenuService.isOpen) return;
    if (MenuService.current.anchorItem === root) return;

    MenuService.close();
  }

  Keys.onPressed: event => {
    if (MenuService.isOpen && MenuService.current.type?.(event)) event.accepted = true;
  }

  Keys.onReturnPressed: root.trigger()
  Keys.onEnterPressed: root.trigger()
  Keys.onSpacePressed: root.trigger()

  MouseArea {
    anchors.fill: parent

    enabled: root.interactive
    hoverEnabled: root.interactive
    cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor

    onEntered: {
      root.forceActiveFocus(Qt.MouseFocusReason);
      root.openMenu();
    }

    onPressed: root.forceActiveFocus(Qt.MouseFocusReason)
    onClicked: root.press()
  }

  HoverHandler {
    id: hover
  }

  TextMetrics {
    id: labelMetrics

    font.family: ConfigService.font.name
    font.pointSize: ConfigService.font.size
    text: root.label
  }

  RowLayout {
    id: content

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: ConfigService.space
    anchors.rightMargin: ConfigService.space

    spacing: ConfigService.space

    Item {
      id: leadingSlot

      Layout.alignment: Qt.AlignVCenter

      visible: root.leading !== null
      implicitWidth: Math.max(root.leadingSize, leadingLoader.implicitWidth)
      implicitHeight: Math.max(root.leadingSize, leadingLoader.implicitHeight)

      Loader {
        id: leadingLoader

        anchors.centerIn: parent

        active: root.leading !== null
        sourceComponent: root.leading
      }
    }

    ColumnLayout {
      id: labels

      Layout.fillWidth: true

      visible: !root.wideTrailing || root.label !== "" || root.sublabel !== ""

      spacing: 0

      MesaMarquee {
        id: labelText

        Layout.fillWidth: true

        visible: root.label !== ""
        text: root.label
        color: root.interactive ? root.foreground : root.muted
        running: root.highlighted || hover.hovered
      }

      MesaMarquee {
        Layout.fillWidth: true

        visible: root.sublabel !== ""
        text: root.sublabel
        color: root.muted
        running: root.highlighted || hover.hovered
      }
    }

    MesaText {
      id: valueText

      Layout.alignment: Qt.AlignVCenter

      visible: root.value !== ""
      text: root.value
      color: root.foreground
    }
  }
}

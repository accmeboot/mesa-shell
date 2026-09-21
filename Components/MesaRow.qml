import QtQuick
import QtQuick.Layouts
import QtQuick.Window

import qs.Services

Rectangle {
  id: root

  property string label
  property color labelColor: ThemeService.colors.foreground
  property string sublabel
  property string value
  property string fallback
  property color valueColor: ThemeService.colors.foreground
  property Component leading: null
  property MesaRowMenu menu: null
  property bool interactive: false
  property bool wideTrailing: false

  default property alias trailing: trailingRow.data

  readonly property bool containsFocus: {
    for (let item = root.Window.activeFocusItem; item; item = item.parent) {
      if (item === root) return true;
    }

    return false;
  }

  readonly property bool highlighted: root.containsFocus
  readonly property color contentColor: root.highlighted ? ThemeService.colors.background : ThemeService.colors.foreground
  readonly property color mutedColor: Qt.alpha(root.contentColor, 0.6)
  readonly property color surfaceColor: root.highlighted ? ThemeService.colors.highlight : ThemeService.colors.background
  readonly property color accentColor: root.highlighted ? ThemeService.colors.background : ThemeService.colors.highlight

  readonly property bool hasValue: root.value !== ""

  readonly property int leadingSize: Math.round(ConfigService.font.size * 0.5)

  function tone(color: color): color {
    return root.highlighted ? root.contentColor : color;
  }

  signal clicked()

  Layout.fillWidth: true

  implicitWidth: content.implicitWidth + ConfigService.spaceMd * 2
  implicitHeight: Math.max(content.implicitHeight, ConfigService.controlHeight)
  color: root.highlighted ? ThemeService.colors.highlight : "transparent"

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

  RowLayout {
    id: content

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: ConfigService.spaceMd
    anchors.rightMargin: ConfigService.spaceMd

    spacing: 0

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
      Layout.leftMargin: leadingSlot.visible ? ConfigService.spaceMd : 0

      visible: !root.wideTrailing || root.label !== "" || root.sublabel !== ""

      spacing: 0

      MesaText {
        Layout.fillWidth: true

        visible: root.label !== ""
        text: root.label
        color: root.highlighted ? root.contentColor : root.labelColor
        elide: Text.ElideRight
      }

      MesaText {
        Layout.fillWidth: true

        visible: root.sublabel !== ""
        text: root.sublabel
        color: root.mutedColor
        elide: Text.ElideRight
      }
    }

    MesaText {
      id: valueText

      Layout.alignment: Qt.AlignVCenter
      Layout.leftMargin: labels.visible ? ConfigService.spaceMd : 0

      visible: root.hasValue || root.fallback !== ""
      text: root.hasValue ? root.value : root.fallback
      color: {
        if (root.highlighted) return root.contentColor;
        return root.hasValue ? root.valueColor : ThemeService.colors.on_surface;
      }
    }

    RowLayout {
      id: trailingRow

      Layout.fillWidth: root.wideTrailing
      Layout.alignment: Qt.AlignVCenter
      Layout.leftMargin: trailingRow.implicitWidth > 0 && (labels.visible || valueText.visible) ? ConfigService.spaceMd : 0

      spacing: ConfigService.spaceSm
    }
  }
}

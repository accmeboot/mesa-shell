import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

import qs.Services

PopupWindow {
  id: root

  property QsMenuHandle menuHandle: null
  property Item anchorItem: null
  property bool submenu: false
  property PopupWindow parentMenu: null
  property Item openRow: null
  property int currentIndex: -1
  property bool autoSelect: false

  readonly property bool isOpen: root.menuHandle !== null
  readonly property bool shouldShow: root.isOpen && opener.children.values.length > 0
  readonly property int rowPadding: ConfigService.gapSmall
  readonly property int indicatorSize: ConfigService.iconSize
  readonly property bool hasIndicators: opener.children.values.some(entry => entry.icon !== "" || entry.buttonType !== QsMenuButtonType.None)
  readonly property bool hasToggles: opener.children.values.some(entry => entry.buttonType === QsMenuButtonType.CheckBox)
  readonly property int indicatorWidth: root.hasToggles ? Math.max(root.indicatorSize, toggleMetrics.implicitWidth) : root.indicatorSize

  visible: root.shouldShow
  color: "transparent"
  anchor.item: root.anchorItem
  anchor.edges: root.submenu ? Edges.Right | Edges.Top : Edges.Bottom | Edges.Left
  anchor.gravity: root.submenu ? Edges.Right | Edges.Bottom : Edges.Bottom | Edges.Right
  anchor.adjustment: PopupAdjustment.Flip | PopupAdjustment.Slide
  implicitWidth: background.implicitWidth
  implicitHeight: background.implicitHeight

  onShouldShowChanged: if (root.shouldShow && root.autoSelect) root.selectFirst()

  onBackerVisibilityChanged: if (!root.backingWindowVisible && root.shouldShow) root.closeAll()

  onOpenRowChanged: {
    if (!submenuLoader.item) {
      if (!root.openRow) return;

      submenuLoader.setSource(Qt.resolvedUrl("MesaMenu.qml"), {
        submenu: true,
        parentMenu: root,
        anchorItem: root.openRow,
        menuHandle: root.openRow.modelData
      });

      return;
    }

    const submenu = submenuLoader.item;

    submenu.menuHandle = null;

    if (!root.openRow) return;

    submenu.anchorItem = root.openRow;
    submenu.menuHandle = root.openRow.modelData;
  }

  function selectFirst(): void {
    root.currentIndex = -1;
    root.step(1);
  }

  function step(delta: int): void {
    const entries = opener.children.values;

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
    const entry = opener.children.values[root.currentIndex] ?? null;

    if (!entry || entry.isSeparator || !entry.enabled) return;

    if (entry.hasChildren) {
      root.openSubmenu(root.currentIndex);
      return;
    }

    entry.triggered();
    root.closeAll();
  }

  function openSubmenu(index: int): void {
    root.openRow = rows.itemAt(index);

    const submenu = submenuLoader.item;

    if (!submenu) return;

    submenu.autoSelect = true;

    if (submenu.shouldShow) submenu.selectFirst();
  }

  function enterSubmenu(): void {
    const entry = opener.children.values[root.currentIndex] ?? null;

    if (!entry || !entry.enabled || !entry.hasChildren) return;

    root.openSubmenu(root.currentIndex);
  }

  function closeSubmenu(): void {
    const menu = root.activeMenu();

    if (menu.parentMenu) menu.parentMenu.openRow = null;
  }

  function activeMenu(): var {
    const submenu = submenuLoader.item;

    return submenu && submenu.isOpen ? submenu.activeMenu() : root;
  }

  function openAt(item, handle): void {
    const toggle = root.isOpen && root.anchorItem === item;
    root.close();

    if (toggle) return;

    root.anchorItem = item;
    root.menuHandle = handle;
  }

  function close(): void {
    root.openRow = null;
    root.currentIndex = -1;
    root.autoSelect = false;
    submenuLoader.source = "";
    root.menuHandle = null;
  }

  function closeAll(): void {
    if (root.parentMenu) root.parentMenu.closeAll();
    else root.close();
  }

  QsMenuOpener {
    id: opener

    menu: root.menuHandle
  }

  Loader { id: submenuLoader }

  MesaIndicator {
    id: toggleMetrics

    visible: false
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

        model: opener.children

        Rectangle {
          id: row

          required property QsMenuEntry modelData
          required property int index

          readonly property bool highlighted: row.index === root.currentIndex
          readonly property color foreground: {
            if (!modelData.enabled) return ThemeService.colors.on_surface;
            return highlighted ? ThemeService.colors.background : ThemeService.colors.foreground;
          }

          Layout.fillWidth: true
          implicitWidth: modelData.isSeparator ? 0 : content.implicitWidth + root.rowPadding * 2
          implicitHeight: modelData.isSeparator ? ConfigService.border : content.implicitHeight + ConfigService.gap
          color: {
            if (modelData.isSeparator) return ThemeService.colors.on_surface;
            return highlighted ? ThemeService.colors.highlight : ThemeService.colors.background;
          }

          RowLayout {
            id: content

            visible: !row.modelData.isSeparator
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: root.rowPadding
            anchors.rightMargin: root.rowPadding
            spacing: ConfigService.gap

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
              Layout.fillWidth: true
              text: row.modelData.text
              color: row.foreground
            }

            MesaIcon {
              visible: row.modelData.hasChildren
              name: "pan-end"
              size: root.indicatorSize
              color: row.foreground
            }
          }

          MouseArea {
            id: mouse

            anchors.fill: parent
            enabled: !row.modelData.isSeparator && row.modelData.enabled
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: {
              root.currentIndex = row.index;
              root.openRow = row.modelData.hasChildren ? row : null;
            }
            onClicked: {
              if (row.modelData.hasChildren) {
                root.openRow = row;
                return;
              }

              row.modelData.triggered();
              root.closeAll();
            }
          }
        }
      }
    }
  }
}

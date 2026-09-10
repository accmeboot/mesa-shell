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

  readonly property bool isOpen: root.menuHandle !== null
  readonly property bool shouldShow: root.isOpen && opener.children.values.length > 0
  readonly property int rowPadding: Math.round(ConfigService.spacing / 2)
  readonly property int indicatorSize: Math.round(ConfigService.font.size * 1.5)
  readonly property bool hasIndicators: opener.children.values.some(entry => entry.icon !== "" || entry.buttonType !== QsMenuButtonType.None)

  visible: root.shouldShow
  color: "transparent"
  grabFocus: true
  anchor.item: root.anchorItem
  anchor.edges: root.submenu ? Edges.Right | Edges.Top : Edges.Bottom | Edges.Left
  anchor.gravity: root.submenu ? Edges.Right | Edges.Bottom : Edges.Bottom | Edges.Right
  implicitWidth: background.implicitWidth
  implicitHeight: background.implicitHeight

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

  function openAt(item, handle): void {
    const toggle = root.isOpen && root.anchorItem === item;
    root.close();

    if (toggle) return;

    root.anchorItem = item;
    root.menuHandle = handle;
  }

  function close(): void {
    root.openRow = null;
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

  Rectangle {
    id: background

    anchors.fill: parent
    implicitWidth: entries.implicitWidth + border.width * 2
    implicitHeight: entries.implicitHeight + border.width * 2
    color: ThemeService.colors.background
    border.width: ConfigService.border
    border.color: ThemeService.colors.on_surface
    focus: true
    Keys.onEscapePressed: root.closeAll()

    ColumnLayout {
      id: entries

      anchors.fill: parent
      anchors.margins: background.border.width
      spacing: 0

      Repeater {
        model: opener.children

        Rectangle {
          id: row

          required property QsMenuEntry modelData

          readonly property bool highlighted: mouse.containsMouse
          readonly property color foreground: {
            if (!modelData.enabled) return ThemeService.colors.on_surface;
            return highlighted ? ThemeService.colors.background : ThemeService.colors.foreground;
          }

          Layout.fillWidth: true
          implicitWidth: modelData.isSeparator ? 0 : content.implicitWidth + root.rowPadding * 2
          implicitHeight: modelData.isSeparator ? ConfigService.border : content.implicitHeight + ConfigService.spacing
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
            spacing: ConfigService.spacing

            Item {
              visible: root.hasIndicators
              Layout.preferredWidth: root.indicatorSize
              Layout.preferredHeight: root.indicatorSize

              MesaIndicator {
                id: indicator

                anchors.centerIn: parent
                visible: row.modelData.buttonType !== QsMenuButtonType.None
                checked: row.modelData.checkState === Qt.Checked
                radio: row.modelData.buttonType === QsMenuButtonType.RadioButton
                color: row.foreground
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
            onEntered: root.openRow = row.modelData.hasChildren ? row : null
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

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

import qs.Services
import qs.Components

RowLayout {
  id: root

  readonly property bool choosing: DmenuService.mode === "choose"
  readonly property bool hasArguments: !choosing && /\s/.test(searchField.text.trim())

  property var filteredItems: {
    if (hasArguments) {
      return [];
    }

    const source = choosing ? DmenuService.items : DmenuService.applications;
    const query = searchField.text.trim().toLowerCase();
    if (query === "") {
      return source;
    }
    return source.filter(item => item.toLowerCase().includes(query));
  }

  function selectNext(): void {
    if (menuList.currentIndex < 0) {
      menuList.currentIndex = 0;
    } else {
      menuList.incrementCurrentIndex();
    }
  }

  function selectPrevious(): void {
    if (menuList.currentIndex < 0) {
      menuList.currentIndex = 0;
    } else {
      menuList.decrementCurrentIndex();
    }
  }

  function submit(): void {
    const hasSelection = menuList.currentIndex >= 0 && menuList.currentIndex < filteredItems.length;

    if (choosing) {
      if (hasSelection) {
        DmenuService.resolve(filteredItems[menuList.currentIndex]);
      }
      return;
    }

    if (hasSelection) {
      DmenuService.execute(filteredItems[menuList.currentIndex]);
      return;
    }

    const command = searchField.text.trim();
    if (command !== "") {
      DmenuService.execute(command);
    }
  }

  spacing: 0

  MesaButton {
    Layout.fillHeight: true
    icon: DmenuService.isOpen ? "window-close" : "cm_runterm"
    onClicked: DmenuService.isOpen ? DmenuService.close() : DmenuService.open()
  }

  RowLayout {
    id: menuRow

    visible: DmenuService.isOpen
    spacing: 0

    onVisibleChanged: {
      if (!visible) {
        searchField.text = "";
        menuList.currentIndex = 0;
      }
    }
    MesaInput {
      id: searchField

      Layout.fillHeight: true
      Layout.minimumWidth: 150

      focus: true

      onTextChanged: {
        menuList.currentIndex = 0;
      }

      Keys.onEscapePressed: DmenuService.close()
      Keys.onReturnPressed: root.submit()
      Keys.onEnterPressed: root.submit()
      Keys.onRightPressed: root.selectNext()
      Keys.onDownPressed: root.selectNext()
      Keys.onTabPressed: root.selectNext()
      Keys.onLeftPressed: root.selectPrevious()
      Keys.onUpPressed: root.selectPrevious()
      Keys.onBacktabPressed: root.selectPrevious()
    }

    Rectangle {
      id: listFrame

      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.maximumWidth: implicitWidth

      visible: menuList.count > 0
      implicitWidth: listRow.implicitWidth + border.width * 2

      color: "transparent"
      border.color: ThemeService.colors.on_surface
      border.width: ConfigService.border

      RowLayout {
        id: listRow

        anchors.fill: parent
        anchors.margins: listFrame.border.width

        spacing: 0

        MesaIcon {
          Layout.alignment: Qt.AlignVCenter

          name: "pan-start"
          size: Math.round(ConfigService.font.size * 1.5)
          color: menuList.atXBeginning ? ThemeService.colors.on_surface : ThemeService.colors.foreground
        }

        ScrollView {
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.preferredWidth: Math.ceil(menuList.contentWidth)

          clip: true

          ScrollBar.vertical.policy: ScrollBar.AlwaysOff
          ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

          spacing: 0

          ListView {
            id: menuList
            model: root.filteredItems
            orientation: Qt.Horizontal

            keyNavigationEnabled: true

            highlightFollowsCurrentItem: true
            highlightMoveDuration: 0

            interactive: false

            spacing: 0

            WheelHandler {
              acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

              property int accumulated: 0

              onWheel: event => {
                accumulated += event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x;

                while (accumulated <= -120) {
                  accumulated += 120;
                  menuList.incrementCurrentIndex();
                }
                while (accumulated >= 120) {
                  accumulated -= 120;
                  menuList.decrementCurrentIndex();
                }
              }
            }

            delegate: MesaButton {
              id: delegateRoot
              required property int index
              required property string modelData

              anchors.verticalCenter: parent?.verticalCenter

              text: delegateRoot.modelData
              border.width: 0

              color: delegateRoot.ListView.isCurrentItem
              ? ThemeService.colors.highlight
              : ThemeService.colors.background

              contentColor: delegateRoot.ListView.isCurrentItem
              ? ThemeService.colors.background
              : ThemeService.colors.foreground

              onClicked: {
                menuList.currentIndex = delegateRoot.index;
                root.submit();
              }
            }
          }
        }

        MesaIcon {
          Layout.alignment: Qt.AlignVCenter

          name: "pan-end"
          size: Math.round(ConfigService.font.size * 1.5)
          color: menuList.atXEnd ? ThemeService.colors.on_surface : ThemeService.colors.foreground
        }
      }
    }
  }
}

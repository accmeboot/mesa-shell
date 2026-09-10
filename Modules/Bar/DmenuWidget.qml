import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

import qs.Services
import qs.Components

RowLayout {
  id: root

  readonly property bool hasArguments: /\s/.test(searchField.text.trim())

  property var filteredApplications: {
    if (hasArguments) {
      return [];
    }

    const query = searchField.text.trim().toLowerCase();
    if (query === "") {
      return DmenuService.applications;
    }
    return DmenuService.applications.filter(app => app.toLowerCase().includes(query));
  }

  function submit(): void {
    const hasSelection = menuList.currentIndex >= 0 && menuList.currentIndex < filteredApplications.length;

    if (hasSelection) {
      DmenuService.execute(filteredApplications[menuList.currentIndex]);
      return;
    }

    const command = searchField.text.trim();
    if (command !== "") {
      DmenuService.execute(command);
    }
  }

  spacing: 0

  MesaButton {
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
      Keys.onDownPressed: {
        menuList.currentIndex = 0;
      }
      Keys.onRightPressed: {
        if (menuList.currentIndex < 0) {
          menuList.currentIndex = 0;
        } else {
          menuList.incrementCurrentIndex();
        }
      }
      Keys.onLeftPressed: {
        if (menuList.currentIndex < 0) {
          menuList.currentIndex = 0;
        } else {
          menuList.decrementCurrentIndex();
        }
      }
    }

    ScrollView {
      Layout.fillWidth: true
      Layout.fillHeight: true

      clip: true

      ScrollBar.vertical.policy: ScrollBar.AlwaysOff
      ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

      spacing: 0

      ListView {
        id: menuList
        model: root.filteredApplications
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
            DmenuService.execute(delegateRoot.modelData);
          }
        }
      }
    }
  }
}

import Quickshell
import QtQuick
import QtQuick.Layouts

import Quickshell.Wayland

import qs.Services
import qs.Components

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: notificationsWindow

      required property var modelData

      screen: modelData

      color: "transparent"

      WlrLayershell.layer: WlrLayer.Top

      readonly property int maxVisible: 4

      property int count: NotificationsService.activeList.count ?? 0

      visible: Boolean(count)

      implicitWidth: notificationsColumn.implicitWidth
      implicitHeight: notificationsColumn.implicitHeight

      anchors {
        top: true
        right: true
      }

      ColumnLayout {
        id: notificationsColumn

        Repeater {
          model: NotificationsService.activeList

          Notification {
            required property int index

            visible: index < notificationsWindow.maxVisible
          }
        }
      }
    }
  }
}

import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Wayland
import QtQuick.Layouts

import qs.Services
import qs.Components
import qs.Modules.Bar.Audio
import qs.Modules.Bar.Battery
import qs.Modules.Bar.Bluetooth
import qs.Modules.Bar.Clock
import qs.Modules.Bar.Display
import qs.Modules.Bar.Dmenu
import qs.Modules.Bar.Mode
import qs.Modules.Bar.Network
import qs.Modules.Bar.Notification
import qs.Modules.Bar.Power
import qs.Modules.Bar.Theme
import qs.Modules.Bar.Tray
import qs.Modules.Bar.Workspaces

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panel

      required property var modelData
      screen: modelData

      color: ThemeService.colors.background

      WlrLayershell.keyboardFocus: dmenu.isOpen || tray.menuOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: Math.max(leftLayout.implicitHeight, rightLayout.implicitHeight)

      ClockWidget {
        id: clock

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
      }

      RowLayout {
        id: leftLayout

        anchors.left: parent.left
        anchors.right: clock.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        spacing: 0

        WorkspacesWidget {
          Layout.alignment: Qt.AlignLeft
          screen: modelData
        }
        DmenuWidget {
          id: dmenu
          Layout.fillHeight: true
          Layout.fillWidth: true
          screen: modelData
        }
        ModeWidget {}
        Item { Layout.fillWidth: true }
      }

      RowLayout {
        id: rightLayout

        anchors.left: clock.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        spacing: 0

        Item { Layout.fillWidth: true }

        TrayWidget {
          id: tray
          Layout.fillHeight: true
          Layout.fillWidth: true
          screen: modelData
        }
        NetworkWidget {
          id: network
          Layout.fillHeight: true
          screen: modelData
        }
        BatteryWidget {
          id: battery
          Layout.fillHeight: true
          screen: modelData
        }
        AudioWidget {
          id: audio
          Layout.fillHeight: true
          screen: modelData
        }
        DisplayWidget {
          id: display
          Layout.fillHeight: true
          screen: modelData
        }
        BluetoothWidget {
          id: bluetooth
          Layout.fillHeight: true
          screen: modelData
        }
        ThemeWidget {
          id: theme
          Layout.fillHeight: true
        }
        NotificationWidget {
          id: notification
          Layout.fillHeight: true
        }
        PowerWidget {
          id: power
          Layout.fillHeight: true
          screen: modelData
        }
      }
    }
  }
}

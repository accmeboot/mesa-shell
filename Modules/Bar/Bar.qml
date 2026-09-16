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
      required property var modelData
      screen: modelData

      color: ThemeService.colors.background

      WlrLayershell.keyboardFocus: dmenu.isOpen || tray.menuOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: mainLayout.height

      ClockWidget {
        id: clock

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
      }

      RowLayout {
        id: mainLayout
        anchors.left: parent.left
        anchors.right: parent.right

        spacing: 0

        WorkspacesWidget {
          Layout.alignment: Qt.AlignLeft
          screen: modelData
        }
        DmenuWidget {
          id: dmenu
          Layout.fillHeight: true
          maximumRight: clock.x
          screen: modelData
        }
        ModeWidget {}
        Item { Layout.fillWidth: true }

        TrayWidget {
          id: tray
          Layout.fillHeight: true
          screen: modelData
        }
        NetworkWidget {
          Layout.fillHeight: true
          screen: modelData
        }
        BatteryWidget {
          Layout.fillHeight: true
          screen: modelData
        }
        AudioWidget {
          Layout.fillHeight: true
          screen: modelData
        }
        DisplayWidget {
          Layout.fillHeight: true
          screen: modelData
        }
        BluetoothWidget {
          Layout.fillHeight: true
          screen: modelData
        }
        ThemeWidget {
          Layout.fillHeight: true
        }
        NotificationWidget {
          Layout.fillHeight: true
        }
        PowerWidget {
          Layout.fillHeight: true
          screen: modelData
        }
      }
    }
  }
}

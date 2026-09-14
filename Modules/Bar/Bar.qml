import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Wayland
import QtQuick.Layouts

import qs.Services
import qs.Components

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

      RowLayout {
        id: mainLayout
        anchors.left: parent.left
        anchors.right: parent.right

        spacing: ConfigService.spacing

        SettingsWidget {
          Layout.fillHeight: true
          Layout.rightMargin: -mainLayout.spacing
          screen: modelData
        }

        WorkspacesWidget {
          Layout.alignment: Qt.AlignLeft
          screen: modelData
        }
        ModeWidget {}
        DmenuWidget {
          id: dmenu
          Layout.fillHeight: true
          screen: modelData
        }

        Item { Layout.fillWidth: true }

        TrayWidget {
          id: tray
          Layout.fillHeight: true
          screen: modelData
        }
        NetworkWidget {}
        BatteryWidget {}
        ClockWidget {}
        ThemeWidget {
          Layout.fillHeight: true
          Layout.rightMargin: -mainLayout.spacing
        }
        NotificationWidget {
          Layout.fillHeight: true
        }
      }
    }
  }
}

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

      WlrLayershell.keyboardFocus: {
        if (DmenuService.isOpen) return WlrKeyboardFocus.Exclusive;
        if (tray.menuOpen) return WlrKeyboardFocus.OnDemand;

        return WlrKeyboardFocus.None;
      }

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
        }

        WorkspacesWidget {
          Layout.alignment: Qt.AlignLeft
          screen: modelData
        }
        ModeWidget {}
        DmenuWidget {
          Layout.fillHeight: true
        }

        Item { Layout.fillWidth: true }

        TrayWidget {
          id: tray
          Layout.fillHeight: true
        }
        NetworkWidget {}
        CpuWidget {}
        RamWidget {}
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

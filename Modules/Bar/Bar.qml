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
import qs.Modules.Bar.Dmenu
import qs.Modules.Bar.Mode
import qs.Modules.Bar.Network
import qs.Modules.Bar.Control
import qs.Modules.Bar.Privacy
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
        top: !ConfigService.bottom
        bottom: ConfigService.bottom
        left: true
        right: true
      }

      implicitHeight: Math.max(leftLayout.implicitHeight, rightLayout.implicitHeight) + ConfigService.barPadding * 2 + ConfigService.border

      Rectangle {
        y: ConfigService.bottom ? 0 : parent.height - height
        width: parent.width
        height: ConfigService.border
        color: ThemeService.colors.on_surface
      }

      Item {
        anchors.fill: parent
        anchors.margins: ConfigService.barPadding
        anchors.topMargin: ConfigService.barPadding + (ConfigService.bottom ? ConfigService.border : 0)
        anchors.bottomMargin: ConfigService.barPadding + (ConfigService.bottom ? 0 : ConfigService.border)

        ClockWidget {
          id: clock

          anchors.centerIn: parent
        }

        RowLayout {
          id: leftLayout

          anchors.left: parent.left
          anchors.right: clock.left
          anchors.rightMargin: ConfigService.barPadding
          height: parent.height

          spacing: ConfigService.space

          WorkspacesWidget {
            Layout.alignment: Qt.AlignLeft
            Layout.fillHeight: true
            screen: modelData
          }
          DmenuWidget {
            id: dmenu
            Layout.fillHeight: true
            Layout.fillWidth: true
            screen: modelData
          }
          ModeWidget {
            Layout.fillHeight: true
          }
          Item { Layout.fillWidth: true }
        }

        RowLayout {
          id: rightLayout

          anchors.left: clock.right
          anchors.right: parent.right
          anchors.leftMargin: ConfigService.barPadding
          height: parent.height

          spacing: ConfigService.space

          Item { Layout.fillWidth: true }

          TrayWidget {
            id: tray
            Layout.fillHeight: true
            Layout.fillWidth: true
            screen: modelData
            direction: "left"
          }
          PrivacyWidget {
            id: privacy
            Layout.fillHeight: true
            screen: modelData
            direction: "left"
          }
          NetworkWidget {
            id: network
            Layout.fillHeight: true
            screen: modelData
            direction: "left"
          }
          BatteryWidget {
            id: battery
            Layout.fillHeight: true
            screen: modelData
            direction: "left"
          }
          AudioWidget {
            id: audio
            Layout.fillHeight: true
            screen: modelData
            direction: "left"
            output: true
          }
          AudioWidget {
            id: microphone
            Layout.fillHeight: true
            screen: modelData
            direction: "left"
            output: false
          }
          BluetoothWidget {
            id: bluetooth
            Layout.fillHeight: true
            screen: modelData
            direction: "left"
          }
          ControlWidget {
            id: control
            Layout.fillHeight: true
            screen: modelData
            direction: "left"
          }
        }
      }
    }
  }
}

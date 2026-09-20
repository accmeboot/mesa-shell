import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

MesaPanel {
  id: root

  property string pendingAction: ""

  readonly property string message: {
    switch (root.pendingAction) {
    case "exit": return "Exit the session?";
    case "reboot": return "Restart the system?";
    case "shutdown": return "Shut down the system?";
    default: return "";
    }
  }

  signal requestClose()

  function arm(action: string): void {
    root.pendingAction = root.pendingAction === action ? "" : action;
  }

  function confirm(): void {
    switch (root.pendingAction) {
    case "exit": PowerService.exitSession(); break;
    case "reboot": PowerService.reboot(); break;
    case "shutdown": PowerService.shutdown(); break;
    }

    root.pendingAction = "";
    root.requestClose();
  }

  SystemGroup {}

  MesaSection {
    MesaRow {
      wideTrailing: true

      MesaButton {
        Layout.fillWidth: true

        icon: "lock"

        onClicked: {
          LockService.lock();
          root.requestClose();
        }
      }

      MesaButton {
        Layout.fillWidth: true

        icon: "weather-clear-night"

        onClicked: {
          PowerService.suspend();
          root.requestClose();
        }
      }

      MesaButton {
        Layout.fillWidth: true

        icon: "application-exit"
        color: root.pendingAction === "exit" ? ThemeService.colors.on_surface : ThemeService.colors.surface

        onClicked: root.arm("exit")
      }

      MesaButton {
        Layout.fillWidth: true

        icon: "system-reboot"
        color: root.pendingAction === "reboot" ? ThemeService.colors.on_surface : ThemeService.colors.surface

        onClicked: root.arm("reboot")
      }

      MesaButton {
        Layout.fillWidth: true

        icon: "system-shutdown"
        color: root.pendingAction === "shutdown" ? ThemeService.colors.on_surface : ThemeService.colors.surface
        contentColor: ThemeService.colors.critical

        onClicked: root.arm("shutdown")
      }
    }

    MesaRow {
      visible: root.pendingAction !== ""
      label: root.message

      MesaButton {
        Layout.alignment: Qt.AlignVCenter

        icon: "window-close"
        accent: ThemeService.colors.highlight

        onClicked: root.pendingAction = ""
      }

      MesaButton {
        Layout.alignment: Qt.AlignVCenter

        icon: "dialog-ok"
        accent: ThemeService.colors.critical

        onClicked: root.confirm()
      }
    }
  }
}

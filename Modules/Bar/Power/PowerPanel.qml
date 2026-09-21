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

  function run(action: var): void {
    root.pendingAction = "";
    action();
    root.requestClose();
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
    title: "Session"

    MesaRow {
      id: lockRow

      label: "Lock"
      interactive: true

      leading: MesaIcon {
        name: "lock"
        size: ConfigService.iconSizeSmall
        color: lockRow.contentColor
      }

      onClicked: root.run(() => LockService.lock())
    }

    MesaRow {
      id: suspendRow

      label: "Suspend"
      interactive: true

      leading: MesaIcon {
        name: "weather-clear-night"
        size: ConfigService.iconSizeSmall
        color: suspendRow.contentColor
      }

      onClicked: root.run(() => PowerService.suspend())
    }

    MesaRow {
      id: exitRow

      label: "Log out"
      interactive: true

      leading: MesaIcon {
        name: "application-exit"
        size: ConfigService.iconSizeSmall
        color: exitRow.contentColor
      }

      onClicked: root.arm("exit")
    }

    MesaRow {
      id: rebootRow

      label: "Restart"
      interactive: true

      leading: MesaIcon {
        name: "system-reboot"
        size: ConfigService.iconSizeSmall
        color: rebootRow.contentColor
      }

      onClicked: root.arm("reboot")
    }

    MesaRow {
      id: shutdownRow

      label: "Shut down"
      labelColor: ThemeService.colors.critical
      interactive: true

      leading: MesaIcon {
        name: "system-shutdown"
        size: ConfigService.iconSizeSmall
        color: shutdownRow.highlighted ? shutdownRow.contentColor : ThemeService.colors.critical
      }

      onClicked: root.arm("shutdown")
    }

    MesaRow {
      visible: root.pendingAction !== ""
      label: root.message
      labelColor: ThemeService.colors.attention

      MesaButton {
        Layout.alignment: Qt.AlignVCenter

        flat: true
        icon: "window-close"

        onClicked: root.pendingAction = ""
      }

      MesaButton {
        Layout.alignment: Qt.AlignVCenter

        flat: true
        icon: "dialog-ok"
        contentColor: ThemeService.colors.critical

        onClicked: root.confirm()
      }
    }
  }
}

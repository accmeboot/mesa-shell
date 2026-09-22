import QtQuick

import qs.Services
import qs.Components

MesaPanel {
  id: root

  signal requestClose()

  function run(action: var): void {
    action();
    root.requestClose();
  }

  component ConfirmMenu: MesaRowMenu {
    id: confirmMenu

    signal confirmed()

    MesaMenuEntry {
      isHeader: true
      text: "Are you sure?"
    }

    MesaMenuEntry {
      text: "Confirm"

      onTriggered: confirmMenu.confirmed()
    }
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

      menu: exitMenu

      MesaChevron {}

      ConfirmMenu {
        id: exitMenu

        onConfirmed: root.run(() => PowerService.exitSession())
      }
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

      menu: rebootMenu

      MesaChevron {}

      ConfirmMenu {
        id: rebootMenu

        onConfirmed: root.run(() => PowerService.reboot())
      }
    }

    MesaRow {
      id: shutdownRow

      label: "Shut down"
      interactive: true

      leading: MesaIcon {
        name: "system-shutdown"
        size: ConfigService.iconSizeSmall
        color: shutdownRow.contentColor
      }

      menu: shutdownMenu

      MesaChevron {}

      ConfirmMenu {
        id: shutdownMenu

        onConfirmed: root.run(() => PowerService.shutdown())
      }
    }
  }
}

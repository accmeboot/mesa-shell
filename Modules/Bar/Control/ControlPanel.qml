import QtQuick
import QtQuick.Layouts

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

  BrightnessGroup {}

  MesaSection {
    title: "Settings"

    MesaRow {
      label: "Dark theme"
      interactive: true

      onClicked: ThemeService.toggle()

      MesaIndicator {
        Layout.alignment: Qt.AlignVCenter

        activeFocusOnTab: false
        checked: ThemeService.isDark

        onToggled: ThemeService.toggle()
      }
    }

    MesaRow {
      label: "Do not disturb"
      interactive: true

      onClicked: NotificationsService.toggleDoNotDisturb()

      MesaIndicator {
        Layout.alignment: Qt.AlignVCenter

        activeFocusOnTab: false
        checked: NotificationsService.doNotDisturb

        onToggled: NotificationsService.toggleDoNotDisturb()
      }
    }
  }

  MesaSection {
    title: "Session"

    MesaRow {
      id: lockRow

      label: "Lock"
      interactive: true

      onClicked: root.run(() => LockService.lock())
    }

    MesaRow {
      id: suspendRow

      label: "Suspend"
      interactive: true

      onClicked: root.run(() => PowerService.suspend())
    }

    MesaRow {
      id: exitRow

      label: "Log out"
      interactive: true

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

      menu: shutdownMenu

      MesaChevron {}

      ConfirmMenu {
        id: shutdownMenu

        onConfirmed: root.run(() => PowerService.shutdown())
      }
    }
  }
}

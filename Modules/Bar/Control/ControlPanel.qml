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

  BrightnessGroup {}

  MesaSection {
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

      onClicked: root.run(() => PowerService.exitSession())
    }

    MesaRow {
      id: rebootRow

      label: "Restart"
      interactive: true

      onClicked: root.run(() => PowerService.reboot())
    }

    MesaRow {
      id: shutdownRow

      label: "Shut down"
      interactive: true

      onClicked: root.run(() => PowerService.shutdown())
    }
  }
}

import Quickshell
import QtQuick

import qs.Services
import qs.Components

MesaButton {
  icon: NotificationsService.doNotDisturb ? "notifications-disabled" : "notifications"

  onClicked: NotificationsService.toggleDoNotDisturb()
}

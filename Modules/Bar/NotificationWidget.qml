import Quickshell
import QtQuick

import qs.Services
import qs.Components

MesaButton {
  icon: NotificationsService.doNotDisturb ? "notification-off" : "notification"

  onClicked: NotificationsService.toggleDoNotDisturb()
}

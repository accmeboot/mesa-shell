import QtQuick

import qs.Services
import qs.Components

MesaPanel {
  id: root

  component UserSection: MesaSection {
    id: section

    property var users: []

    visible: section.users.length > 0

    Repeater {
      model: section.users

      MesaRow {
        required property var modelData

        label: modelData.app
        value: modelData.device
      }
    }
  }

  UserSection {
    title: "Microphone"
    users: PrivacyService.micUsers
  }

  UserSection {
    title: "Camera"
    users: PrivacyService.cameraUsers
  }

  UserSection {
    title: "Screen share"
    users: PrivacyService.screenUsers
  }
}

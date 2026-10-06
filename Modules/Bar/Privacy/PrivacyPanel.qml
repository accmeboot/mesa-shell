import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

MesaPanel {
  MesaSection {
    Repeater {
      model: PrivacyService.apps

      MesaRow {
        id: appRow

        required property var modelData

        label: appRow.modelData.app

        Repeater {
          model: ["mic", "camera", "screen"].filter(kind => appRow.modelData.kinds.includes(kind))

          MesaIcon {
            required property string modelData

            Layout.alignment: Qt.AlignVCenter

            name: ({ mic: "audio-input-microphone-high", camera: "camera-web", screen: "screen-shared" })[modelData]
            size: ConfigService.iconSizeSmall
          }
        }
      }
    }
  }
}

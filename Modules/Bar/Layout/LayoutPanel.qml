import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

MesaPanel {
  id: root

  required property var screen

  signal requestClose()

  MesaSection {
    title: "Layout"

    Repeater {
      model: CompositorService.layouts(root.screen.name)

      MesaRow {
        id: row

        required property var modelData

        label: row.modelData.name
        interactive: true

        leading: Component {
          MesaIndicator {
            radio: true
            activeFocusOnTab: false
            checked: row.modelData.current
          }
        }

        MesaIcon {
          Layout.alignment: Qt.AlignVCenter

          name: row.modelData.icon
          size: ConfigService.iconSizeSmall
          color: row.contentColor
        }

        onClicked: {
          CompositorService.setLayout(root.screen.name, row.modelData.index);
          root.requestClose();
        }
      }
    }
  }
}

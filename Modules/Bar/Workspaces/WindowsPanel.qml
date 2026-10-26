import QtQuick
import Quickshell

import qs.Services
import qs.Components

MesaPanel {
  MesaSection {
    Repeater {
      model: CompositorService.windows

      MesaRow {
        id: windowRow

        required property var modelData

        readonly property string appName: DesktopEntries.heuristicLookup(windowRow.modelData.appId)?.name.toLowerCase() ?? windowRow.modelData.appId

        label: `[${windowRow.appName}] ${windowRow.modelData.title}`
        interactive: true

        onClicked: {
          windowRow.modelData.activate();
          PanelService.close("windows");
        }

        Rectangle {
          parent: windowRow

          visible: windowRow.modelData.urgent

          x: Math.round(width / 2)
          y: x
          width: Math.round(ConfigService.font.size / 2)
          height: width

          color: ThemeService.colors.critical
        }
      }
    }
  }
}

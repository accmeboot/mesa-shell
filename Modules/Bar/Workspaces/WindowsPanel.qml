import QtQuick
import Quickshell

import qs.Services
import qs.Components

MesaPanel {
  Component.onCompleted: CompositorService.refreshWindows()

  MesaSection {
    Repeater {
      model: CompositorService.windows

      MesaRow {
        id: windowRow

        required property var modelData

        readonly property string appName: DesktopEntries.heuristicLookup(windowRow.modelData.appId)?.name.toLowerCase() ?? windowRow.modelData.appId

        label: `[${windowRow.appName}] ${windowRow.modelData.title}`
        interactive: true
        leading: focusedIndicator

        Component {
          id: focusedIndicator

          MesaIndicator {
            radio: true
            activeFocusOnTab: false
            checked: windowRow.modelData.focused
          }
        }

        Component.onCompleted: if (windowRow.modelData.focused) Qt.callLater(() => windowRow.forceActiveFocus())

        onClicked: {
          windowRow.modelData.activate();
          PanelService.close("windows");
        }

        Rectangle {
          parent: windowRow

          visible: windowRow.modelData.urgent

          readonly property int overlap: Math.round(width / 2)

          x: windowRow.labelPosition.x - overlap
          y: windowRow.labelPosition.y - overlap
          width: Math.round(ConfigService.font.size / 2)
          height: width

          color: ThemeService.colors.critical
        }
      }
    }
  }
}

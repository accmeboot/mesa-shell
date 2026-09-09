import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components
import qs.Modules.Settings.Common
import qs.Modules.Settings.Audio
import qs.Modules.Settings.Display
import qs.Modules.Settings.Network
import qs.Modules.Settings.Bluetooth
import qs.Modules.Settings.About

Rectangle {
  id: root

  property string pendingAction: ""

  readonly property int barHeight: Math.max(headerRow.implicitHeight, actions.implicitHeight) + Math.round(ConfigService.spacing / 2)

  readonly property string view: SettingsService.view
  readonly property bool onHome: root.view === SettingsService.home
  readonly property string title: {
    switch (root.view) {
    case "audio": return "Audio";
    case "display": return "Display";
    case "network": return "Network";
    case "bluetooth": return "Bluetooth";
    case "about": return "About";
    default: return "Settings";
    }
  }

  implicitHeight: layout.implicitHeight + root.border.width * 2
  color: ConfigService.colors.background

  border.color: ConfigService.colors.on_surface
  border.width: ConfigService.border

  focus: true

  Keys.onEscapePressed: {
    if (root.pendingAction !== "") root.pendingAction = "";
    else if (root.onHome) SettingsService.close();
    else SettingsService.back();
  }

  Component { id: home; HomeView {} }
  Component { id: audio; AudioView {} }
  Component { id: display; DisplayView {} }
  Component { id: network; NetworkView {} }
  Component { id: bluetooth; BluetoothView {} }
  Component { id: about; AboutView {} }

  ColumnLayout {
    id: layout

    anchors.fill: parent
    anchors.margins: root.border.width

    spacing: 0

    Rectangle {
      Layout.fillWidth: true

      implicitHeight: root.barHeight
      color: ConfigService.colors.surface

      HoverHandler {
        enabled: !root.onHome
        cursorShape: Qt.PointingHandCursor
      }

      TapHandler {
        enabled: !root.onHome

        onTapped: SettingsService.back()
      }

      RowLayout {
        id: headerRow

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: ConfigService.spacing
        anchors.rightMargin: ConfigService.spacing

        spacing: ConfigService.spacing

        MesaIcon {
          id: back

          Layout.alignment: Qt.AlignVCenter

          visible: !root.onHome
          name: "arrow-left"
          size: Math.round(ConfigService.font.size * 1.2)
          color: ConfigService.colors.foreground
        }

        MesaText {
          id: title

          Layout.fillWidth: true

          text: root.title
          font.bold: true
          elide: Text.ElideRight
        }
      }
    }

    Divider {}

    Flickable {
      id: scroll

      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.topMargin: ConfigService.spacing
      Layout.bottomMargin: ConfigService.spacing
      Layout.preferredHeight: content.implicitHeight

      clip: true
      boundsBehavior: Flickable.StopAtBounds
      contentWidth: scroll.width
      contentHeight: content.implicitHeight

      Loader {
        id: content

        width: scroll.width

        sourceComponent: {
          switch (root.view) {
          case "audio": return audio;
          case "display": return display;
          case "network": return network;
          case "bluetooth": return bluetooth;
          case "about": return about;
          default: return home;
          }
        }

        onLoaded: scroll.contentY = 0
      }
    }

    Divider {}

    Rectangle {
      Layout.fillWidth: true

      implicitHeight: root.barHeight
      color: ConfigService.colors.surface

      RowLayout {
        id: actions

        anchors.fill: parent

        spacing: 0

        MesaButton {
          Layout.fillWidth: true
          Layout.fillHeight: true

          icon: "lock"

          onClicked: {
            PowerService.lock();
            SettingsService.close();
          }
        }

        MesaButton {
          Layout.fillWidth: true
          Layout.fillHeight: true

          icon: "suspend"

          onClicked: {
            PowerService.suspend();
            SettingsService.close();
          }
        }

        MesaButton {
          Layout.fillWidth: true
          Layout.fillHeight: true

          icon: "restart"

          onClicked: root.pendingAction = "reboot"
        }

        MesaButton {
          Layout.fillWidth: true
          Layout.fillHeight: true

          icon: "power"
          contentColor: ConfigService.colors.critical

          onClicked: root.pendingAction = "shutdown"
        }
      }
    }
  }

  ConfirmDialog {
    anchors.fill: parent
    anchors.margins: root.border.width

    visible: root.pendingAction !== ""
    message: root.pendingAction === "shutdown" ? "Shut down the system?" : "Restart the system?"
    confirmLabel: root.pendingAction === "shutdown" ? "Shut down" : "Restart"
    confirmColor: ConfigService.colors.critical

    onCancelled: root.pendingAction = ""

    onConfirmed: {
      if (root.pendingAction === "shutdown") PowerService.shutdown();
      else PowerService.reboot();

      root.pendingAction = "";
      SettingsService.close();
    }
  }
}

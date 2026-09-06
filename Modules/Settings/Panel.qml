import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components
import qs.Modules.Settings.Common
import qs.Modules.Settings.Audio
import qs.Modules.Settings.Network
import qs.Modules.Settings.Bluetooth
import qs.Modules.Settings.About

Rectangle {
  id: root

  readonly property string view: SettingsService.view
  readonly property bool onHome: root.view === SettingsService.home
  readonly property string title: {
    switch (root.view) {
    case "audio": return "Audio";
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
    if (root.onHome) SettingsService.close();
    else SettingsService.back();
  }

  Component { id: home; HomeView {} }
  Component { id: audio; AudioView {} }
  Component { id: network; NetworkView {} }
  Component { id: bluetooth; BluetoothView {} }
  Component { id: about; AboutView {} }

  ColumnLayout {
    id: layout

    anchors.fill: parent
    anchors.margins: root.border.width

    spacing: 0

    Rectangle {
      id: header

      Layout.fillWidth: true

      visible: !root.onHome
      implicitHeight: back.implicitHeight + ConfigService.spacing
      color: ConfigService.colors.surface

      HoverHandler {
        cursorShape: Qt.PointingHandCursor
      }

      TapHandler {
        onTapped: SettingsService.back()
      }

      RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: ConfigService.spacing
        anchors.rightMargin: ConfigService.spacing

        spacing: ConfigService.spacing

        MesaIcon {
          id: back

          Layout.alignment: Qt.AlignVCenter

          name: "arrow-left"
          size: Math.round(ConfigService.font.size * 1.3)
          color: ConfigService.colors.foreground
        }

        MesaText {
          Layout.fillWidth: true

          text: root.title
          font.bold: true
          elide: Text.ElideRight
        }
      }
    }

    Divider {
      visible: header.visible
    }

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
          case "network": return network;
          case "bluetooth": return bluetooth;
          case "about": return about;
          default: return home;
          }
        }

        onLoaded: scroll.contentY = 0
      }
    }
  }
}

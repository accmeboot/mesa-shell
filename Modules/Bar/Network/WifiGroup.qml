import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking

import qs.Services
import qs.Components

MesaSection {
  id: root

  readonly property WifiDevice device: Networking.devices.values.find(device => device.type === DeviceType.Wifi) || null
  readonly property var networks: root.device && Networking.wifiEnabled ? root.device.networks.values : []

  title: "Wi-Fi"
  visible: root.device !== null

  Binding {
    target: root.device
    property: "scannerEnabled"
    value: Networking.wifiEnabled
  }

  MesaRow {
    label: "Enabled"
    value: !Networking.wifiHardwareEnabled ? "Blocked by rfkill" : ""
    valueColor: ThemeService.colors.critical
    interactive: Networking.wifiHardwareEnabled

    onClicked: Networking.wifiEnabled = !Networking.wifiEnabled

    MesaIndicator {
      Layout.alignment: Qt.AlignVCenter

      activeFocusOnTab: false
      enabled: Networking.wifiHardwareEnabled
      checked: Networking.wifiEnabled

      onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
    }
  }

  MesaRow {
    visible: Networking.wifiEnabled && root.networks.length === 0
    label: "Scanning"
    labelColor: ThemeService.colors.attention
  }

  ScriptModel {
    id: networksModel

    values: root.networks
  }

  Repeater {
    model: networksModel

    ColumnLayout {
      id: entry

      required property WifiNetwork modelData

      property string error: ""

      readonly property WifiNetwork network: entry.modelData
      readonly property bool needsPassword: !entry.network.known && entry.network.security !== WifiSecurityType.Open && entry.network.security !== WifiSecurityType.Owe

      function activate(): void {
        entry.error = "";

        if (entry.network.connected) {
          entry.network.disconnect();
          return;
        }

        entry.network.connect();
      }

      function connectWithPassword(): void {
        if (passwordEntry.text === "") return;

        entry.error = "";
        entry.network.connectWithPsk(passwordEntry.text);
      }

      Layout.fillWidth: true

      spacing: 0

      Connections {
        target: entry.network

        function onConnectionFailed(reason: int): void {
          switch (reason) {
          case ConnectionFailReason.NoSecrets:
            entry.error = "Wrong password";
            break;
          case ConnectionFailReason.WifiAuthTimeout:
            entry.error = "Authentication timed out";
            break;
          case ConnectionFailReason.WifiNetworkLost:
            entry.error = "Network lost";
            break;
          case ConnectionFailReason.WifiClientDisconnected:
            entry.error = "Disconnected";
            break;
          default:
            entry.error = "Connection failed";
          }
        }

        function onConnectedChanged(): void {
          if (entry.network.connected) entry.error = "";
        }
      }

      MesaRow {
        id: networkRow

        label: entry.network.name
        value: {
          switch (entry.network.state) {
          case ConnectionState.Connecting: return "Connecting";
          case ConnectionState.Disconnecting: return "Disconnecting";
          default: return entry.network.connected ? "Connected" : "";
          }
        }
        valueColor: entry.network.stateChanging ? ThemeService.colors.attention : ThemeService.colors.ok
        interactive: true
        menu: networkMenu

        MesaIcon {
          Layout.alignment: Qt.AlignVCenter

          name: entry.network.security === WifiSecurityType.Open || entry.network.security === WifiSecurityType.Owe ? "unlock" : "lock"
          size: ConfigService.iconSize
          color: networkRow.mutedColor
        }

        MesaChevron {}

        MesaRowMenu {
          id: networkMenu

          MesaMenuEntry {
            id: passwordEntry

            visible: entry.needsPassword
            enabled: !entry.network.stateChanging
            isInput: true
            secret: true
            placeholder: "Password"

            onTriggered: entry.connectWithPassword()
          }

          MesaMenuEntry {
            visible: entry.needsPassword
            enabled: !entry.network.stateChanging && passwordEntry.text !== ""
            text: "Confirm"

            onTriggered: entry.connectWithPassword()
          }

          MesaMenuEntry {
            visible: entry.needsPassword
            text: "Cancel"
          }

          MesaMenuEntry {
            visible: !entry.needsPassword
            enabled: !entry.network.stateChanging
            text: {
              switch (entry.network.state) {
              case ConnectionState.Connecting: return "Connecting";
              case ConnectionState.Disconnecting: return "Disconnecting";
              default: return entry.network.connected ? "Disconnect" : "Connect";
              }
            }

            onTriggered: entry.activate()
          }

          MesaMenuEntry {
            visible: entry.network.known
            text: "Forget"

            onTriggered: entry.network.forget()
          }
        }
      }

      MesaRow {
        visible: entry.error !== ""
        label: entry.error
        labelColor: ThemeService.colors.critical
      }
    }
  }
}

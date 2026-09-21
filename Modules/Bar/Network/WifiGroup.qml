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

  property WifiNetwork promptedNetwork: null
  property string password: ""

  title: "Wi-Fi"
  visible: root.device !== null

  onPromptedNetworkChanged: root.password = ""

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
      readonly property bool prompting: root.promptedNetwork === entry.network
      readonly property bool needsPassword: !entry.network.known && entry.network.security !== WifiSecurityType.Open && entry.network.security !== WifiSecurityType.Owe

      function activate(): void {
        entry.error = "";

        if (entry.network.connected) {
          entry.network.disconnect();
          return;
        }

        if (entry.prompting) {
          entry.network.connectWithPsk(root.password);
          return;
        }

        if (entry.needsPassword) {
          root.promptedNetwork = entry.network;
          return;
        }

        entry.network.connect();
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

          if (!entry.needsPassword) return;

          root.promptedNetwork = entry.network;
        }

        function onConnectedChanged(): void {
          if (!entry.network.connected) return;

          entry.error = "";
          if (entry.prompting) root.promptedNetwork = null;
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
        visible: entry.prompting
        wideTrailing: true

        MesaInput {
          id: passwordInput

          function restoreFocus(): void {
            if (!passwordInput.visible) return;

            passwordInput.forceActiveFocus();
            passwordInput.cursorPosition = passwordInput.text.length;
          }

          Layout.fillWidth: true

          visible: entry.prompting
          echoMode: TextInput.Password
          placeholderText: "Password"
          passwordCharacter: "*"
          backgroundColor: ThemeService.colors.background
          text: root.password

          Keys.onEscapePressed: root.promptedNetwork = null

          onTextEdited: root.password = passwordInput.text
          onAccepted: entry.activate()
          onVisibleChanged: passwordInput.restoreFocus()

          Component.onCompleted: Qt.callLater(passwordInput.restoreFocus)
        }

        MesaButton {
          Layout.alignment: Qt.AlignVCenter

          flat: true
          icon: "window-close"

          onClicked: root.promptedNetwork = null
        }

        MesaButton {
          Layout.alignment: Qt.AlignVCenter

          flat: true
          enabled: !entry.network.stateChanging
          icon: "dialog-ok"

          onClicked: entry.activate()
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

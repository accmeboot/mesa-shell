import QtQuick
import QtQuick.Layouts
import Quickshell.Networking

import qs.Services
import qs.Components
import qs.Modules.Settings.Common

PanelSection {
  id: root

  readonly property WifiDevice device: Networking.devices.values.find(device => device.type === DeviceType.Wifi) || null
  readonly property var networks: root.device && Networking.wifiEnabled ? root.device.networks.values : []

  property WifiNetwork selectedNetwork: null
  property WifiNetwork promptedNetwork: null
  property string password: ""

  title: "Wi-Fi"
  visible: root.device !== null

  onSelectedNetworkChanged: {
    if (root.selectedNetwork !== root.promptedNetwork) root.promptedNetwork = null;
  }

  onPromptedNetworkChanged: root.password = ""

  Binding {
    target: root.device
    property: "scannerEnabled"
    value: Networking.wifiEnabled
  }

  PanelRow {
    indented: true
    label: "Enabled"
    value: Networking.wifiHardwareEnabled ? "" : "Blocked by rfkill"
    valueColor: ConfigService.colors.critical

    MesaIndicator {
      Layout.alignment: Qt.AlignVCenter

      enabled: Networking.wifiHardwareEnabled
      checked: Networking.wifiEnabled

      onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
    }
  }

  PanelRow {
    visible: Networking.wifiEnabled && root.networks.length === 0
    indented: true
    label: "Scanning"
    labelColor: ConfigService.colors.attention
  }

  Repeater {
    model: root.networks

    ColumnLayout {
      id: entry

      required property WifiNetwork modelData

      property string error: ""

      readonly property bool selected: root.selectedNetwork === entry.modelData
      readonly property bool prompting: root.promptedNetwork === entry.modelData
      readonly property bool needsPassword: !entry.modelData.known && entry.modelData.security !== WifiSecurityType.Open && entry.modelData.security !== WifiSecurityType.Owe

      function activate(): void {
        const network = entry.modelData;

        entry.error = "";

        if (network.connected) {
          network.disconnect();
          return;
        }

        if (entry.prompting) {
          network.connectWithPsk(root.password);
          return;
        }

        if (entry.needsPassword) {
          root.promptedNetwork = network;
          return;
        }

        network.connect();
      }

      Layout.fillWidth: true

      spacing: 0

      onSelectedChanged: {
        if (!entry.selected) entry.error = "";
      }

      Connections {
        target: entry.modelData

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

          root.selectedNetwork = entry.modelData;
          root.promptedNetwork = entry.modelData;
        }

        function onConnectedChanged(): void {
          if (!entry.modelData.connected) return;

          entry.error = "";
          if (entry.prompting) root.promptedNetwork = null;
        }
      }

      PanelRow {
        label: entry.modelData.name
        value: {
          switch (entry.modelData.state) {
          case ConnectionState.Connecting: return "Connecting";
          case ConnectionState.Disconnecting: return "Disconnecting";
          default: return entry.modelData.connected ? "Connected" : "";
          }
        }
        valueColor: entry.modelData.stateChanging ? ConfigService.colors.attention : ConfigService.colors.ok
        interactive: true
        selected: entry.selected

        leading: Item {
          implicitWidth: dot.implicitWidth
          implicitHeight: dot.implicitHeight

          MesaIcon {
            id: dot

            visible: entry.modelData.connected
            name: "dot"
            size: Math.round(ConfigService.font.size * 0.5)
            color: ConfigService.colors.ok
          }
        }

        onClicked: root.selectedNetwork = entry.selected ? null : entry.modelData

        MesaIcon {
          Layout.alignment: Qt.AlignVCenter

          name: entry.modelData.security === WifiSecurityType.Open || entry.modelData.security === WifiSecurityType.Owe ? "lock-open" : "lock"
          size: Math.round(ConfigService.font.size * 1.1)
          color: ConfigService.colors.on_surface
        }
      }

      PanelRow {
        visible: entry.selected
        selected: true
        indented: true
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
          text: root.password

          Keys.onEscapePressed: root.promptedNetwork = null

          onTextEdited: root.password = passwordInput.text
          onAccepted: entry.activate()
          onVisibleChanged: passwordInput.restoreFocus()

          Component.onCompleted: Qt.callLater(passwordInput.restoreFocus)
        }

        MesaButton {
          Layout.alignment: Qt.AlignVCenter

          enabled: !entry.modelData.stateChanging
          text: {
            switch (entry.modelData.state) {
            case ConnectionState.Connecting: return "Connecting";
            case ConnectionState.Disconnecting: return "Disconnecting";
            default: return entry.modelData.connected ? "Disconnect" : "Connect";
            }
          }

          onClicked: entry.activate()
        }

        MesaButton {
          Layout.alignment: Qt.AlignVCenter

          visible: entry.modelData.known && !entry.prompting
          text: "Forget"

          onClicked: entry.modelData.forget()
        }

        MesaButton {
          Layout.alignment: Qt.AlignVCenter

          visible: entry.prompting
          text: "Cancel"

          onClicked: root.promptedNetwork = null
        }
      }

      PanelRow {
        visible: entry.error !== ""
        selected: entry.selected
        indented: true
        label: entry.error
        labelColor: ConfigService.colors.critical
      }
    }
  }
}

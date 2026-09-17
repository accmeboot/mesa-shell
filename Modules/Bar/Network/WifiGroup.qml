import QtQuick
import QtQuick.Layouts
import Quickshell.Networking

import qs.Services
import qs.Components

MesaSection {
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

  actions: [
    MesaText {
      Layout.alignment: Qt.AlignVCenter

      visible: !Networking.wifiHardwareEnabled
      text: "Blocked by rfkill"
      color: ThemeService.colors.critical
    },
    MesaIndicator {
      Layout.alignment: Qt.AlignVCenter

      enabled: Networking.wifiHardwareEnabled
      checked: Networking.wifiEnabled

      onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
    }
  ]

  MesaRow {
    visible: Networking.wifiEnabled && root.networks.length === 0
    label: "Scanning"
    labelColor: ThemeService.colors.attention
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
      Layout.topMargin: entry.selected ? ConfigService.gapSmall : 0
      Layout.bottomMargin: entry.selected ? ConfigService.gapSmall : 0

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

      MesaRow {
        label: entry.modelData.name
        value: {
          switch (entry.modelData.state) {
          case ConnectionState.Connecting: return "Connecting";
          case ConnectionState.Disconnecting: return "Disconnecting";
          default: return entry.modelData.connected ? "Connected" : "";
          }
        }
        valueColor: entry.modelData.stateChanging ? ThemeService.colors.attention : ThemeService.colors.ok
        interactive: true
        selected: entry.selected

        onClicked: root.selectedNetwork = entry.selected ? null : entry.modelData

        MesaIcon {
          Layout.alignment: Qt.AlignVCenter

          name: entry.modelData.security === WifiSecurityType.Open || entry.modelData.security === WifiSecurityType.Owe ? "unlock" : "lock"
          size: ConfigService.iconSizeSmall
          color: ThemeService.colors.on_surface
        }

        MesaIcon {
          Layout.alignment: Qt.AlignVCenter

          name: "pan-end"
          size: ConfigService.iconSizeSmall
          color: ThemeService.colors.foreground
          rotation: entry.selected ? -90 : 90
        }
      }

      MesaRow {
        visible: entry.selected
        selected: true
        wideTrailing: entry.prompting

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

          visible: !entry.prompting
          enabled: !entry.modelData.stateChanging
          text: {
            switch (entry.modelData.state) {
            case ConnectionState.Connecting: return "Connecting";
            case ConnectionState.Disconnecting: return "Disconnecting";
            default: return entry.modelData.connected ? "Disconnect" : "Connect";
            }
          }
          color: !enabled ? ThemeService.colors.attention : entry.modelData.connected ? ThemeService.colors.critical : ThemeService.colors.highlight
          contentColor: ThemeService.colors.background
          disabledContentColor: ThemeService.colors.background

          onClicked: entry.activate()
        }

        MesaButton {
          Layout.alignment: Qt.AlignVCenter

          visible: entry.modelData.known && !entry.prompting
          text: "Forget"
          color: ThemeService.colors.critical
          contentColor: ThemeService.colors.background

          onClicked: entry.modelData.forget()
        }

        MesaButton {
          Layout.alignment: Qt.AlignVCenter

          visible: entry.prompting
          icon: "window-close"
          color: ThemeService.colors.critical
          contentColor: ThemeService.colors.background

          onClicked: root.promptedNetwork = null
        }

        MesaButton {
          Layout.alignment: Qt.AlignVCenter

          visible: entry.prompting
          enabled: !entry.modelData.stateChanging
          icon: "dialog-ok"
          color: enabled ? ThemeService.colors.highlight : ThemeService.colors.attention
          contentColor: ThemeService.colors.background
          disabledContentColor: ThemeService.colors.background

          onClicked: entry.activate()
        }
      }

      MesaRow {
        visible: entry.error !== ""
        selected: entry.selected
        label: entry.error
        labelColor: ThemeService.colors.critical
      }
    }
  }
}

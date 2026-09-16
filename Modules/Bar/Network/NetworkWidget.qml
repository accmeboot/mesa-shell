import Quickshell.Networking
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

RowLayout {
  id: root

  required property var screen

  property bool isOpen: false

  readonly property var device: Networking.devices.values.find(device => device.connected)

  readonly property string ssid: {
    if (!root.device || root.device.type !== DeviceType.Wifi) return "";

    const connected = root.device.networks.values.find(network => network.state === ConnectionState.Connected);

    return connected ? connected.name : "";
  }

  readonly property bool connected: {
    if (!root.device) return false;

    if (root.device.type === DeviceType.Wifi) return root.ssid !== "";

    return true;
  }

  readonly property string icon: {
    if (!root.device) return "network-wireless-offline";

    if (root.device.type === DeviceType.Wifi) return root.connected ? "network-wireless-signal-excellent" : "network-wireless-offline";

    return "network-wired";
  }

  spacing: 0

  MesaButton {
    id: button

    Layout.fillHeight: true

    icon: root.icon
    contentColor: ColorService.status(root.connected)

    onClicked: root.isOpen = !root.isOpen
    horizontalPadding: ConfigService.spacing * 2
  }

  MesaPopup {
    open: root.isOpen
    screen: root.screen
    exclude: root
    namespace: "mesa-network"
    anchorRight: root.x + button.x + button.width
    keyboardFocus: WlrKeyboardFocus.OnDemand

    content: NetworkPanel {}

    onDismissed: root.isOpen = false
  }
}

import Quickshell.Networking

import qs.Services
import qs.Components

MesaPanelWidget {
  id: root

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

  panel: "network"
  icon: {
    if (!root.device) return "network-wireless-offline";

    if (root.device.type === DeviceType.Wifi) return root.connected ? "network-wireless-signal-excellent" : "network-wireless-offline";

    return "network-wired";
  }
  iconColor: ColorService.status(root.connected)

  content: NetworkPanel {}
}

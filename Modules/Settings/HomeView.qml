import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import Quickshell.I3
import Quickshell.Networking
import Quickshell.Services.Pipewire

import qs.Services
import qs.Components
import qs.Modules.Settings.Common
import qs.Modules.Settings.Audio
import qs.Modules.Settings.Display

ColumnLayout {
  id: root

  readonly property var devices: Networking.devices.values
  readonly property WifiDevice wifiDevice: root.devices.find(device => device.type === DeviceType.Wifi) || null
  readonly property WiredDevice wiredDevice: root.devices.find(device => device.type === DeviceType.Wired) || null

  readonly property string wifiName: {
    const device = root.wifiDevice;

    if (!device) return "";

    const network = device.networks.values.find(network => network.connected);

    return network ? network.name : "";
  }

  readonly property bool online: root.wifiName !== "" || (root.wiredDevice?.connected ?? false)

  readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
  readonly property var connectedDevices: Bluetooth.devices.values.filter(device => device.connected)

  spacing: ConfigService.spacing

  PwObjectTracker {
    objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource].filter(node => node)
  }

  PanelSection {
    title: "Audio"
    view: "audio"
    value: AudioService.nodeName(Pipewire.defaultAudioSink)
    valueColor: ThemeService.colors.foreground

    Repeater {
      model: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []

      AudioNodeRow {
        required property PwNode modelData

        node: modelData
        showName: false
      }
    }

    Repeater {
      model: Pipewire.defaultAudioSource ? [Pipewire.defaultAudioSource] : []

      AudioNodeRow {
        required property PwNode modelData

        node: modelData
        showName: false
        icon: "audio-input-microphone-high"
        mutedIcon: "audio-input-microphone-muted"
      }
    }
  }

  PanelSection {
    title: "Display"
    view: "display"
    value: I3.focusedMonitor?.name ?? ""
    valueColor: ThemeService.colors.foreground

    BrightnessRow {
      visible: BrightnessService.available
    }
  }

  PanelSection {
    title: "Network"
    view: "network"
    value: {
      if (root.wifiName !== "") return root.wifiName;
      if (root.wiredDevice?.connected) return root.wiredDevice.name;
      if (!root.wifiDevice && !root.wiredDevice) return "No devices";
      if (root.wifiDevice && !Networking.wifiHardwareEnabled) return "Blocked";
      if (root.wifiDevice && !Networking.wifiEnabled) return "Off";

      return "Disconnected";
    }
    valueColor: {
      const colors = ThemeService.colors;

      if (root.online) return colors.ok;
      if (!root.wifiDevice && !root.wiredDevice) return colors.on_surface;
      if (root.wifiDevice && !Networking.wifiHardwareEnabled) return colors.critical;
      if (root.wifiDevice && !Networking.wifiEnabled) return colors.on_surface;

      return colors.critical;
    }
  }

  PanelSection {
    title: "Bluetooth"
    view: "bluetooth"
    visible: root.adapter !== null
    value: {
      switch (root.adapter?.state) {
      case BluetoothAdapterState.Enabled: {
        const devices = root.connectedDevices;

        if (devices.length === 0) return "On";
        if (devices.length === 1) return devices[0].name;

        return `${devices.length} connected`;
      }
      case BluetoothAdapterState.Enabling: return "Enabling";
      case BluetoothAdapterState.Disabling: return "Disabling";
      case BluetoothAdapterState.Blocked: return "Blocked";
      default: return "Off";
      }
    }
    valueColor: {
      const colors = ThemeService.colors;

      switch (root.adapter?.state) {
      case BluetoothAdapterState.Enabled: return root.connectedDevices.length > 0 ? colors.ok : colors.foreground;
      case BluetoothAdapterState.Enabling:
      case BluetoothAdapterState.Disabling:
        return colors.attention;
      case BluetoothAdapterState.Blocked: return colors.critical;
      default: return colors.on_surface;
      }
    }
  }

  PanelSection {
    title: "System"
    view: "about"
    value: SystemService.hostname || "Unknown"
    valueColor: SystemService.hostname ? ThemeService.colors.foreground : ThemeService.colors.on_surface
  }
}

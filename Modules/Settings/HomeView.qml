import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

import qs.Services
import qs.Components
import qs.Modules.Settings.Common
import qs.Modules.Settings.Audio

ColumnLayout {
  id: root

  readonly property var devices: Networking.devices.values
  readonly property WifiDevice wifiDevice: root.devices.find(device => device.type === DeviceType.Wifi) || null
  readonly property var connectedDevice: root.devices.find(device => device.connected) || null

  readonly property string wifiName: {
    const device = root.wifiDevice;

    if (!device) return "";

    const network = device.networks.values.find(network => network.connected);

    return network ? network.name : "";
  }

  readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
  readonly property int connectedCount: Bluetooth.devices.values.filter(device => device.connected).length

  readonly property UPowerDevice battery: UPower.displayDevice
  readonly property bool hasBattery: root.battery?.isLaptopBattery && root.battery.isPresent

  spacing: ConfigService.spacing

  PwObjectTracker {
    objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource].filter(node => node)
  }

  RowLayout {
    Layout.fillWidth: true
    Layout.leftMargin: ConfigService.spacing
    Layout.rightMargin: ConfigService.spacing

    spacing: ConfigService.spacing

    PanelTile {
      label: root.wifiDevice ? "Wi-Fi" : "Network"
      view: "network"
      active: root.wifiDevice ? Networking.wifiEnabled : root.connectedDevice !== null
      sublabel: {
        if (root.wifiDevice && !Networking.wifiHardwareEnabled) return "Blocked";
        if (root.wifiDevice && !Networking.wifiEnabled) return "Off";
        if (root.wifiName !== "") return root.wifiName;
        if (root.connectedDevice) return root.connectedDevice.name;

        return "Disconnected";
      }
    }

    PanelTile {
      readonly property bool blocked: root.adapter?.state === BluetoothAdapterState.Blocked

      visible: root.adapter !== null
      label: "Bluetooth"
      view: "bluetooth"
      active: root.adapter?.enabled ?? false
      sublabel: {
        if (blocked) return "Blocked";
        if (!root.adapter?.enabled) return "Off";
        if (root.connectedCount > 0) return `${root.connectedCount} connected`;

        return "On";
      }
    }
  }

  PanelSection {
    title: "Audio"
    view: "audio"
    filled: true

    Repeater {
      model: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []

      AudioNodeRow {
        required property PwNode modelData

        node: modelData
        selectable: false
      }
    }

    Repeater {
      model: Pipewire.defaultAudioSource ? [Pipewire.defaultAudioSource] : []

      AudioNodeRow {
        required property PwNode modelData

        node: modelData
        selectable: false
        icon: "microphone"
        mutedIcon: "microphone-off"
      }
    }
  }

  PanelSection {
    title: "System"
    view: "about"
    filled: true

    PanelRow {
      visible: root.hasBattery
      label: "Battery"
      value: {
        const percentage = Math.round((root.battery?.percentage ?? 0) * 100);
        const charging = root.battery?.state === UPowerDeviceState.Charging;
        const remaining = charging ? root.battery.timeToFull : root.battery?.timeToEmpty ?? 0;

        if (remaining <= 0) return `${percentage}%`;

        const hours = Math.floor(remaining / 3600);
        const minutes = Math.round(remaining % 3600 / 60);
        const duration = hours > 0 ? `${hours}h ${minutes}m` : `${minutes}m`;

        return `${percentage}% · ${duration} ${charging ? "to full" : "left"}`;
      }
      valueColor: ColorService.threshold(Math.round((root.battery?.percentage ?? 0) * 100), 50, 20)
    }

    PanelRow {
      label: "Uptime"
      value: SystemService.uptime > 0 ? SystemService.formatUptime(SystemService.uptime) : "Unknown"
      valueColor: ConfigService.colors.foreground
    }

    PanelRow {
      label: "OS"
      value: SystemService.distro || "Unknown"
      valueColor: ConfigService.colors.foreground
    }
  }
}

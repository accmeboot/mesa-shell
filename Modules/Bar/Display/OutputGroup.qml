import QtQuick

import qs.Services
import qs.Components

MesaSection {
  id: root

  readonly property var info: CompositorService.outputInfo(CompositorService.focusedOutput)

  title: "Output"

  Component.onCompleted: CompositorService.refreshOutputs()

  MesaRow {
    label: "Name"
    value: root.info?.name ?? ""
    fallback: "Unknown"
  }

  MesaRow {
    label: "Resolution"
    value: root.info?.width > 0 ? `${root.info.width}x${root.info.height}` : ""
    fallback: "Unknown"
  }

  MesaRow {
    label: "Refresh"
    value: root.info?.refresh > 0 ? `${root.info.refresh.toFixed(2)} Hz` : ""
    fallback: "Unknown"
  }

  MesaRow {
    label: "Scale"
    value: root.info?.scale > 0 ? root.info.scale.toFixed(2) : ""
    fallback: "Unknown"
  }

  MesaRow {
    visible: (root.info?.transform ?? "") !== ""
    label: "Transform"
    value: root.info?.transform ?? ""
  }

  MesaRow {
    visible: (root.info?.adaptiveSync ?? "") !== ""
    label: "Adaptive sync"
    value: root.info?.adaptiveSync ?? ""
    valueColor: root.info?.adaptiveSync === "enabled" ? ThemeService.colors.ok : ThemeService.colors.on_surface
  }
}

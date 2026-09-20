import Quickshell.I3

import qs.Components

MesaSection {
  id: root

  readonly property var info: I3.focusedMonitor?.lastIpcObject ?? null

  title: "Monitor"

  MesaRow {
    label: "Make"
    value: root.info?.make ?? ""
    fallback: "Unknown"
  }

  MesaRow {
    label: "Model"
    value: root.info?.model ?? ""
    fallback: "Unknown"
  }

  MesaRow {
    label: "Serial"
    value: root.info?.serial ?? ""
    fallback: "Unknown"
  }
}

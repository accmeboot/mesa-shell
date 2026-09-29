import qs.Services
import qs.Components

MesaSection {
  id: root

  readonly property var info: CompositorService.outputInfo(CompositorService.focusedOutput)

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

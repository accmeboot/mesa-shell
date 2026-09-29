import qs.Services
import qs.Components

MesaPanelWidget {
  id: root

  readonly property var current: CompositorService.currentLayout(root.screen.name)

  panel: "layout"
  visible: root.current !== null
  icon: root.current?.icon ?? ""

  content: LayoutPanel {
    screen: root.screen

    onRequestClose: PanelService.close("layout")
  }
}

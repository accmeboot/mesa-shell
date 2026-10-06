import qs.Services
import qs.Components

MesaPanelWidget {
  id: root

  visible: PrivacyService.active

  panel: "privacy"
  icon: "eye"
  accent: ThemeService.colors.attention

  readonly property bool requested: PanelService.current === root.panel

  onVisibleChanged: if (!root.visible) PanelService.close(root.panel)
  onRequestedChanged: if (root.requested && !root.visible) PanelService.close(root.panel)

  content: PrivacyPanel {}
}

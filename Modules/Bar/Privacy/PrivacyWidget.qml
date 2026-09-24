import qs.Services
import qs.Components

MesaPanelWidget {
  id: root

  visible: PrivacyService.active

  panel: "privacy"
  icons: {
    const color = ThemeService.colors.attention;
    const icons = [];

    if (PrivacyService.micActive) icons.push({ icon: "audio-input-microphone-high", color: color });
    if (PrivacyService.cameraActive) icons.push({ icon: "camera-web", color: color });
    if (PrivacyService.screenActive) icons.push({ icon: "screen-shared", color: color });

    return icons;
  }

  onVisibleChanged: if (!root.visible) PanelService.close(root.panel)

  content: PrivacyPanel {}
}

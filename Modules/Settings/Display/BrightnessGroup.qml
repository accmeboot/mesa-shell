import qs.Services
import qs.Modules.Settings.Common

PanelSection {
  title: "Brightness"

  BrightnessRow {
    visible: BrightnessService.available
  }

  PanelRow {
    visible: !BrightnessService.available
    indented: true
    label: "No backlight device"
    labelColor: ThemeService.colors.on_surface
  }
}

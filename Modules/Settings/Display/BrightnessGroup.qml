import qs.Services
import qs.Modules.Settings.Common

PanelSection {
  title: "Brightness"
  visible: BrightnessService.available

  BrightnessRow {}
}

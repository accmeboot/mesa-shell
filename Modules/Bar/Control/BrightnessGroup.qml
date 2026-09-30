import qs.Services
import qs.Components

MesaSection {
  title: "Brightness"
  visible: BrightnessService.available

  BrightnessRow {}
}

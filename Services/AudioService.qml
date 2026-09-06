pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

Singleton {
  id: root

  readonly property var headphones: /headset|hands-?free|headphone|earphone|earbud|earpods|airpods|buds|beats|momentum|arctis|hyperx|steelseries|astro|kraken|virtuoso|quantum|pro ?x/

  function deviceIcon(node: PwNode): string {
    if (!node || node.isStream) return "speaker";

    const properties = node.properties ?? {};
    const text = [properties["device.form-factor"], properties["api.bluez5.icon"], properties["device.icon-name"], properties["api.alsa.card.name"], node.description, node.nickname, node.name].join(" ").toLowerCase();

    return root.headphones.test(text) ? "headphones" : "speaker";
  }
}

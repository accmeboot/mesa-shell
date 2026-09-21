pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

Singleton {
  id: root

  function nodeName(node: PwNode): string {
    if (!node) return "";
    if (!node.isStream) return node.nickname || node.description || node.name;

    const application = node.properties["application.name"] || node.name;
    const media = node.properties["media.name"];

    return media && media !== application ? `${application}: ${media}` : application;
  }
}

pragma Singleton

import QtQuick
import Quickshell

import qs.Services

Singleton {
  function threshold(value: real, warning: real, critical: real): color {
    const colors = ThemeService.colors;

    if (critical >= warning) {
      if (value > critical) return colors.critical;
      if (value > warning) return colors.attention;
    } else {
      if (value < critical) return colors.critical;
      if (value < warning) return colors.attention;
    }

    return colors.ok;
  }

  function status(ok: bool): color {
    return ok ? ThemeService.colors.ok : ThemeService.colors.critical;
  }
}

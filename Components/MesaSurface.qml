import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

import qs.Services

Control {
  id: root

  property bool attached: false
  property real minimumWidth: 0
  property real maximumWidth: Infinity

  readonly property int corner: ConfigService.nestedRadius(ConfigService.popupInset)
  readonly property bool shaped: root.attached && root.corner > 0
  readonly property int flare: root.shaped ? root.corner : 0
  readonly property real implicitBodyWidth: Math.max(root.minimumWidth, Math.min(root.maximumWidth, root.implicitContentWidth + root.padding * 2))

  implicitWidth: root.implicitBodyWidth + root.flare * 2

  padding: ConfigService.popupInset
  leftPadding: root.padding + root.flare
  rightPadding: root.padding + root.flare
  leftInset: root.flare
  rightInset: root.flare
  hoverEnabled: false

  background: Item {
    Rectangle {
      anchors.fill: parent

      visible: !root.shaped
      color: ThemeService.colors.background
      radius: root.corner
      border.color: ThemeService.colors.on_surface
      border.width: ConfigService.border
    }

    Shape {
      id: shape

      function trace(closed: bool): string {
        const w = shape.width;
        const h = shape.height;
        const s = ConfigService.border / 2;
        const f = root.flare;
        const c = root.corner;
        const flip = ConfigService.bottom;
        const p = (x, y) => `${x} ${flip ? h - y : y}`;
        const arc = (radius, convex, x, y) => `A ${radius} ${radius} 0 0 ${convex === flip ? 1 : 0} ${p(x, y)}`;

        const outline = `M ${p(s - f, s)} ${arc(f, false, s, s + f)} L ${p(s, h - c)} ${arc(c - s, true, c, h - s)} L ${p(w - c, h - s)} ${arc(c - s, true, w - s, h - c)} L ${p(w - s, s + f)} ${arc(f, false, w - s + f, s)}`;

        return closed ? `${outline} L ${p(w - s + f, 0)} L ${p(s - f, 0)} Z` : outline;
      }

      anchors.fill: parent

      visible: root.shaped
      preferredRendererType: Shape.CurveRenderer

      ShapePath {
        fillColor: ThemeService.colors.background
        strokeColor: "transparent"

        PathSvg { path: shape.trace(true) }
      }

      ShapePath {
        fillColor: "transparent"
        strokeColor: ThemeService.colors.on_surface
        strokeWidth: ConfigService.border

        PathSvg { path: shape.trace(false) }
      }
    }
  }
}

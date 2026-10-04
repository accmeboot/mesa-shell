import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

import qs.Services
import qs.Components

Scope {
  Binding {
    target: Quickshell
    property: "watchFiles"
    value: false
    when: LockService.locked
  }

  WlSessionLock {
    locked: LockService.locked

    onLockedChanged: {
      if (!locked) LockService.locked = false;
    }

    WlSessionLockSurface {
      id: surface

      color: ThemeService.colors.background

      Image {
        anchors.fill: parent

        source: ThemeService.wallpaper
        fillMode: Image.PreserveAspectCrop
        asynchronous: true

        sourceSize.width: Math.round(width * (surface.screen?.devicePixelRatio ?? 1))
        sourceSize.height: Math.round(height * (surface.screen?.devicePixelRatio ?? 1))
      }

      Rectangle {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: ConfigService.spaceLg

        implicitWidth: date.implicitWidth + ConfigService.spaceLg * 2
        implicitHeight: date.implicitHeight + ConfigService.spaceMd * 2

        color: ThemeService.colors.background

        MesaText {
          id: date

          anchors.centerIn: parent

          text: Qt.formatDateTime(clock.date, ConfigService.dateTimeFormat)
          font.pointSize: ConfigService.font.size * 1.5

          SystemClock {
            id: clock
            precision: SystemClock.Minutes
          }
        }
      }

      Rectangle {
        id: bar

        readonly property real stroke: ConfigService.border * 3

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: ConfigService.spaceLg

        implicitWidth: row.implicitWidth + ConfigService.spaceMd
        implicitHeight: row.implicitHeight + ConfigService.spaceMd * 2

        color: ThemeService.colors.background

        focus: true

        Keys.onPressed: event => {
          if (LockService.authenticating) return;

          if (event.key === Qt.Key_CapsLock) {
            if (!event.isAutoRepeat) LockService.capsLock = !LockService.capsLock;
          } else if (event.key === Qt.Key_Escape) {
            if (LockService.password !== "") flash.trigger(ThemeService.colors.highlight, true);
            LockService.input("");
          } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            LockService.submit();
          } else if (event.key === Qt.Key_Backspace) {
            if (LockService.password === "") return;

            LockService.input(LockService.password.slice(0, -1));
            flash.trigger(ThemeService.colors.attention, false);
          } else {
            const code = event.text.charCodeAt(0);
            if (!(code >= 32 && code !== 127)) return;

            if (event.text.toLowerCase() !== event.text.toUpperCase()) {
              LockService.capsLock = (event.text === event.text.toUpperCase()) !== Boolean(event.modifiers & Qt.ShiftModifier);
            }

            LockService.input(LockService.password + event.text);
            flash.trigger(ThemeService.colors.highlight, false);
          }

          event.accepted = true;
        }

        RowLayout {
          id: row

          anchors.fill: parent
          anchors.leftMargin: ConfigService.spaceMd

          spacing: ConfigService.spaceMd

          MesaIcon {
            name: "im-user"
            size: ConfigService.iconSizeLarge
            color: LockService.failed ? ThemeService.colors.critical : ThemeService.colors.foreground
          }

          Item {
            Layout.fillHeight: true
            Layout.preferredWidth: Math.ceil(longest.width) + ConfigService.spaceMd * 2

            TextMetrics {
              id: longest

              font: status.font
              text: "CAPS"
            }

            MesaText {
              id: status

              anchors.centerIn: parent

              visible: LockService.authenticating || LockService.capsLock

              text: LockService.authenticating ? "..." : "CAPS"
              color: ThemeService.colors.attention
            }
          }

          RowLayout {
            spacing: 0

            MesaButton {
              icon: "application-exit"
              iconSize: ConfigService.iconSizeLarge
              onClicked: PowerService.exitSession()
            }

            MesaButton {
              icon: "system-reboot"
              iconSize: ConfigService.iconSizeLarge
              onClicked: PowerService.reboot()
            }

            MesaButton {
              icon: "system-shutdown"
              iconSize: ConfigService.iconSizeLarge
              onClicked: PowerService.shutdown()
            }
          }
        }

        Shape {
          id: flash

          readonly property real perimeter: 2 * (width + height - bar.stroke * 2)
          property real position: 0
          property real segment: 0
          property color color: ThemeService.colors.highlight

          function trigger(color: color, full: bool): void {
            flash.color = color;
            flash.segment = full ? flash.perimeter : Math.max(flash.height, flash.perimeter / 8);
            flash.position = full ? 0 : Math.random() * flash.perimeter;
            fade.restart();
          }

          anchors.fill: parent

          opacity: 0

          NumberAnimation on opacity {
            id: fade

            running: false
            from: 1
            to: 0
            duration: 400
            easing.type: Easing.InQuad
          }

          ShapePath {
            strokeColor: flash.color
            strokeWidth: bar.stroke
            fillColor: "transparent"
            strokeStyle: ShapePath.DashLine
            capStyle: ShapePath.SquareCap
            joinStyle: ShapePath.MiterJoin
            dashPattern: [flash.segment / bar.stroke, flash.perimeter * 2 / bar.stroke]
            dashOffset: (flash.perimeter * 2 + flash.segment - flash.position) / bar.stroke

            startX: bar.stroke / 2
            startY: bar.stroke / 2

            PathLine { x: flash.width - bar.stroke / 2; y: bar.stroke / 2 }
            PathLine { x: flash.width - bar.stroke / 2; y: flash.height - bar.stroke / 2 }
            PathLine { x: bar.stroke / 2; y: flash.height - bar.stroke / 2 }
            PathLine { x: bar.stroke / 2; y: bar.stroke / 2 }
            PathLine { x: flash.width - bar.stroke / 2; y: bar.stroke / 2 }
            PathLine { x: flash.width - bar.stroke / 2; y: flash.height - bar.stroke / 2 }
            PathLine { x: bar.stroke / 2; y: flash.height - bar.stroke / 2 }
            PathLine { x: bar.stroke / 2; y: bar.stroke / 2 }
          }
        }
      }
    }
  }
}

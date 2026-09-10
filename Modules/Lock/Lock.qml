import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

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

        source: ConfigService.wallpaper
        fillMode: Image.PreserveAspectCrop
        asynchronous: true

        sourceSize.width: Math.round(width * (surface.screen?.devicePixelRatio ?? 1))
        sourceSize.height: Math.round(height * (surface.screen?.devicePixelRatio ?? 1))
      }

      Rectangle {
        anchors.fill: parent

        color: ThemeService.colors.background
        opacity: 0.9
      }

      RowLayout {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: ConfigService.spacing * 2

        spacing: ConfigService.spacing * 2

        MesaText {
          Layout.alignment: Qt.AlignVCenter

          text: Qt.formatDateTime(clock.date, "dddd HH:mm")
          font.pointSize: ConfigService.font.size * 2

          SystemClock {
            id: clock
            precision: SystemClock.Minutes
          }
        }

        RowLayout {
          spacing: 0

          MesaButton {
            Layout.fillWidth: true

            icon: "application-exit"
            iconSize: ConfigService.font.size * 3

            horizontalPadding: ConfigService.spacing * 3
            verticalPadding: ConfigService.spacing * 3

            onClicked: PowerService.exitSession()
          }

          MesaButton {
            Layout.fillWidth: true

            icon: "system-reboot"
            iconSize: ConfigService.font.size * 3

            horizontalPadding: ConfigService.spacing * 3
            verticalPadding: ConfigService.spacing * 3

            onClicked: PowerService.reboot()
          }

          MesaButton {
            Layout.fillWidth: true

            icon: "system-shutdown"
            iconSize: ConfigService.font.size * 3
            contentColor: ThemeService.colors.critical

            horizontalPadding: ConfigService.spacing * 3
            verticalPadding: ConfigService.spacing * 3

            onClicked: PowerService.shutdown()
          }
        }
      }

      ColumnLayout {
        anchors.centerIn: parent

        spacing: ConfigService.spacing

        RowLayout {
          Layout.alignment: Qt.AlignHCenter

          spacing: ConfigService.spacing

          MesaIcon {
            name: "im-user"
            size: Math.round(ConfigService.font.size * 2.5)
          }

          MesaText {
            text: LockService.user
            font.pointSize: ConfigService.font.size * 2
          }
        }

        MesaInput {
          id: input

          Layout.preferredWidth: Math.round(ConfigService.font.size * 20)

          focus: true
          horizontalAlignment: TextInput.AlignHCenter
          echoMode: TextInput.Password
          passwordCharacter: "·"
          readOnly: LockService.authenticating

          font.pointSize: ConfigService.font.size * 3

          text: LockService.authenticating ? "" : LockService.password

          borderColor: {
            if (LockService.failed) return ThemeService.colors.critical;
            if (LockService.authenticating) return ThemeService.colors.attention;
            return ThemeService.colors.highlight;
          }

          background: Rectangle {
            color: ThemeService.colors.background
            border.color: input.borderColor
            border.width: ConfigService.border * 2
          }

          onTextEdited: LockService.input(text)
          onAccepted: LockService.submit()

          Keys.onEscapePressed: LockService.input("")

          MesaText {
            anchors.centerIn: parent

            visible: LockService.authenticating

            text: "Verifying..."
          }
        }
      }    
    }
  }
}

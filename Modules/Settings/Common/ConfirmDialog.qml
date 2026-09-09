import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Components

Rectangle {
  id: root

  property string message
  property string confirmLabel: "Confirm"
  property color confirmColor: ConfigService.colors.foreground

  readonly property color base: ConfigService.colors.background

  signal confirmed
  signal cancelled

  color: Qt.rgba(root.base.r, root.base.g, root.base.b, 0.9)

  // clicking the scrim dismisses; the box below swallows its own clicks
  MouseArea {
    anchors.fill: parent

    onClicked: root.cancelled()
  }

  Rectangle {
    anchors.centerIn: parent

    width: parent.width - ConfigService.spacing * 4
    implicitHeight: body.implicitHeight + ConfigService.spacing * 2
    color: ConfigService.colors.background

    border.color: ConfigService.colors.on_surface
    border.width: ConfigService.border

    MouseArea {
      anchors.fill: parent
    }

    ColumnLayout {
      id: body

      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: ConfigService.spacing
      anchors.rightMargin: ConfigService.spacing

      spacing: ConfigService.spacing

      MesaText {
        Layout.fillWidth: true

        text: root.message
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
      }

      RowLayout {
        Layout.alignment: Qt.AlignHCenter

        spacing: ConfigService.spacing

        MesaButton {
          text: "Cancel"

          onClicked: root.cancelled()
        }

        MesaButton {
          text: root.confirmLabel
          contentColor: root.confirmColor

          onClicked: root.confirmed()
        }
      }
    }
  }
}

import Quickshell
import QtQuick
import QtQuick.Layouts

import Quickshell.Services.Notifications

import qs.Services
import qs.Components

Rectangle {
  required property var modelData
  readonly property int padding: ConfigService.spacing
  readonly property int inset: root.border.width + root.padding

  id: root

  implicitWidth: 400
  implicitHeight: notificationMainRow.implicitHeight + 2 * root.inset

  clip: true

  color: ConfigService.colors.background

  border.color: ConfigService.colors.on_surface
  border.width: ConfigService.border

  MesaButton {
    icon: "cross"
    color: ConfigService.colors.critical
    contentColor: ConfigService.colors.background
    onClicked: {
        NotificationsService.dismissOrExpireNotification(modelData.id);
    }
  }

  RowLayout {
    id: notificationMainRow

    anchors.fill: parent
    anchors.margins: root.inset

    spacing: root.padding

    MesaIcon {
      id: notificationIcon

      Layout.alignment: Qt.AlignVCenter

      name: 'notification'
      size: Math.round(ConfigService.font.size * 4)
    }

    ColumnLayout {
      id: notificationMainColumn
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      spacing: ConfigService.spacing

      RowLayout {
        id: notificationHeader
        Layout.fillWidth: true
        spacing: ConfigService.spacing

        MesaText {
          Layout.fillWidth: true
          Layout.maximumWidth: Math.ceil(implicitWidth)

          text: modelData.appName || "Unknown"
          color: {
            switch (modelData.urgency) {
              case NotificationUrgency.Critical:
              return ConfigService.colors.critical;
              case NotificationUrgency.Normal:
              return ConfigService.colors.foreground;
              default:
              return ConfigService.colors.foreground;
            }
          }
          font.bold: true
          textFormat: Text.StyledText
          elide: Text.ElideRight
          maximumLineCount: 1
        }
        Item {
          Layout.fillWidth: true
        }
        MesaText {
          id: notificationTime
          text: getTime(modelData.timestamp)
        }
      }

      MesaText {
        Layout.fillWidth: true
        text: modelData.title
        font.bold: true
        elide: Text.ElideRight
        maximumLineCount: 1
      }
      MesaText {
        Layout.fillWidth: true
        text: modelData.body
        wrapMode: Text.Wrap
        maximumLineCount: 2
        elide: Text.ElideRight
        textFormat: Text.StyledText
      }


      Flow {
        id: actionsFlow
        Layout.fillWidth: true
        spacing: ConfigService.spacing
        visible: Boolean(modelData.actions.count)

        Repeater {
          model: modelData.actions

          MesaButton {
            id: action

            required property var modelData

            maximumContentWidth: actionsFlow.width - ConfigService.spacing * 2
            text: action.modelData.text || "OK" + " (" + action.modelData.identifier + ")"
            onClicked: {
              NotificationsService.invokeAction(root.modelData.id, action.modelData.id);
            }
          }
        }
      }
    }
  }


  function getTime(timestamp) {
    var date = new Date(timestamp);
    var hours = String(date.getHours()).padStart(2, '0');
    var minutes = String(date.getMinutes()).padStart(2, '0');

    return hours + ":" + minutes;
  }
}

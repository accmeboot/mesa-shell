import Quickshell
import QtQuick
import QtQuick.Layouts

import Quickshell.Services.Notifications

import qs.Services
import qs.Components

MesaSurface {
  required property var modelData

  id: root

  implicitWidth: Math.round(ConfigService.font.size * 28)

  MouseArea {
    anchors.fill: parent
    z: -1

    enabled: Boolean(root.modelData.defaultActionId)
    cursorShape: Qt.PointingHandCursor

    onClicked: NotificationsService.invokeDefaultAction(root.modelData.id)
  }

  contentItem: RowLayout {
    spacing: ConfigService.space

    MesaIcon {
      id: notificationIcon

      Layout.alignment: Qt.AlignVCenter

      name: 'notifications'
      size: Math.round(ConfigService.font.size * 3)
    }

    ColumnLayout {
      id: notificationMainColumn
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      spacing: ConfigService.space

      RowLayout {
        id: notificationHeader
        Layout.fillWidth: true
        spacing: ConfigService.space

        MesaText {
          Layout.fillWidth: true
          Layout.maximumWidth: Math.ceil(implicitWidth)

          text: modelData.appName || "Unknown"
          color: {
            switch (modelData.urgency) {
              case NotificationUrgency.Critical:
              return ThemeService.colors.critical;
              case NotificationUrgency.Normal:
              return ThemeService.colors.foreground;
              default:
              return ThemeService.colors.foreground;
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
        MesaButton {
          Layout.alignment: Qt.AlignVCenter
          icon: "window-close"
          color: ThemeService.colors.critical
          contentColor: ThemeService.colors.background
          onClicked: {
            NotificationsService.dismissOrExpireNotification(root.modelData.id);
          }
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
        spacing: ConfigService.space
        visible: Boolean(modelData.actions.count)

        Repeater {
          model: modelData.actions

          MesaButton {
            id: action

            required property var modelData

            maximumContentWidth: actionsFlow.width - action.horizontalPadding * 2
            text: action.modelData.text || action.modelData.identifier
            border.width: ConfigService.border
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

import Quickshell
import QtQuick
import QtQuick.Layouts

import Quickshell.Services.Notifications

import qs.Services
import qs.Components

Rectangle {
  required property var modelData
  readonly property int padding: ConfigService.spaceSm
  readonly property int inset: root.border.width + root.padding

  id: root

  implicitWidth: Math.round(ConfigService.font.size * 28)
  implicitHeight: notificationMainRow.implicitHeight + 2 * root.inset

  clip: true

  color: ThemeService.colors.background

  border.color: ThemeService.colors.on_surface
  border.width: ConfigService.border

  MesaButton {
    icon: "window-close"
    color: ThemeService.colors.critical
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.margins: root.border.width
    contentColor: ThemeService.colors.background
    horizontalPadding: ConfigService.spaceSm
    verticalPadding: ConfigService.spaceSm
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

      name: 'notifications'
      size: Math.round(ConfigService.font.size * 3)
    }

    ColumnLayout {
      id: notificationMainColumn
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      spacing: ConfigService.spaceSm

      RowLayout {
        id: notificationHeader
        Layout.fillWidth: true
        spacing: ConfigService.spaceMd

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
        spacing: ConfigService.spaceSm
        visible: Boolean(modelData.actions.count)

        Repeater {
          model: modelData.actions

          MesaButton {
            id: action

            required property var modelData

            maximumContentWidth: actionsFlow.width - action.horizontalPadding * 2
            text: action.modelData.text || "OK" + " (" + action.modelData.identifier + ")"
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

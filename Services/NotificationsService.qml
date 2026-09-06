pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import Quickshell.Services.Notifications

Singleton {
  id: root

  property ListModel activeList: ListModel {}

  property var notificationsActions: []
  property var notificationsWatchers: []

  NotificationServer {
    keepOnReload: false
    imageSupported: true
    actionsSupported: true
    onNotification: notification => root.handleNotification(notification)
  }

  Component {
    id: notificationWatcherComponent
    Connections {
      property var targetNotification

      target: targetNotification

      function onSummaryChanged() {
        root.updateNotificationFromObject(targetNotification);
      }
      function onBodyChanged() {
        root.updateNotificationFromObject(targetNotification);
      }
      function onAppNameChanged() {
        root.updateNotificationFromObject(targetNotification);
      }
      function onUrgencyChanged() {
        root.updateNotificationFromObject(targetNotification);
      }
      function onAppIconChanged() {
        root.updateNotificationFromObject(targetNotification);
      }
      function onImageChanged() {
        root.updateNotificationFromObject(targetNotification);
      }
      function onActionsChanged() {
        root.updateNotificationFromObject(targetNotification);
      }
    }
  }

  function updateNotificationFromObject(notification) {
    var notificationIdx = getNotificationIndexById(notification.id);

    if (notificationIdx === -1)
    return;
    var item = prepareNotificationObject(notification);

    activeList.setProperty(notificationIdx, "title", item.title);
    activeList.setProperty(notificationIdx, "body", item.body);
    activeList.setProperty(notificationIdx, "image", item.image);
    activeList.setProperty(notificationIdx, "icon", item.icon);
    activeList.setProperty(notificationIdx, "actions", item.actions);
    activeList.setProperty(notificationIdx, "urgency", item.urgency);

    notificationsActions = notificationsActions.map(action => {
      if (action.id === item.id) {
        return prepareActionsObject(notification);
      }

      return action;
    });
  }

  function handleNotification(notification) {
    var item = prepareNotificationObject(notification);

    notification.tracked = true;

    var watcher = notificationWatcherComponent.createObject(root, {
      "targetNotification": notification
    });

    activeList.insert(0, item);
    notificationsWatchers.push({
      id: notification.id,
      watcher: watcher
    });
    notificationsActions.push(prepareActionsObject(notification));
  }

  function makeNotificationActionId(notificationId, actionId) {
    return String(notificationId) + ":" + String(actionId);
  }

  function prepareActionsObject(notification) {
    return {
      id: notification.id,
      dismiss: notification.dismiss,
      expire: notification.expire,
      list: notification.actions.map((action, index) => {
        return {
          id: makeNotificationActionId(notification.id, index),
          invoke: action.invoke
        };
      })
    };
  }

  function prepareNotificationObject(notification) {
    return {
      id: notification.id,
      title: notification.summary,
      body: notification.body,
      image: notification.image,
      urgency: notification.urgency,
      icon: notification.appIcon,
      appName: notification.appName,
      expireTimeout: notification.expireTimeout,
      timestamp: Date.now(),
      actions: notification.actions.map((action, index) => {
        return {
          id: makeNotificationActionId(notification.id, index),
          identifier: action.identifier,
          text: action.text
        };
      })
    };
  }

  function dismissOrExpireNotification(notificationId, isExpire = false) {
    var notificationIdx = getNotificationIndexById(notificationId);

    if (notificationIdx === -1)
    return;
    var notification = activeList.get(notificationIdx);

    if (notification) {
      var notificationActions = notificationsActions.find(item => item.id === notificationId);

      if (notificationActions) {
        if (isExpire)
        notificationActions.expire();
        if (!isExpire)
        notificationActions.dismiss();

        removeNotification(notificationId);
      }
    }
  }

  function invokeAction(notificationId, actionId) {
    var actions = notificationsActions.find(item => item.id === notificationId);

    if (actions) {
      var action = actions?.list?.find(item => item.id === actionId);

      if (action) {
        action?.invoke();
        removeNotification(notificationId);
      }
    }
  }

  function removeNotification(notificationId) {
    var notificationIdx = getNotificationIndexById(notificationId);

    if (notificationIdx === -1)
    return;
    var watcher = notificationsWatchers.find(item => item.id === notificationId);

    watcher?.watcher?.destroy();

    activeList.remove(notificationIdx);
    notificationsActions = notificationsActions.filter(item => item.id !== notificationId);
    notificationsWatchers = notificationsWatchers.filter(item => item.id !== notificationId);
  }

  function getNotificationIndexById(notificationId) {
    var idx = -1;

    for (var i = 0; i < activeList.count; i++) {
      var item = activeList.get(i);

      if (item.id === notificationId) {
        idx = i;
        break;
      }
    }

    if (idx === -1)
    console.warn("Notification with id: " + notificationId + "not found");

    return idx;
  }

  property Timer timer: Timer {
    interval: 1000
    running: root.activeList.count > 0
    repeat: true
    onTriggered: () => {
      for (var i = root.activeList.count - 1; i >= 0; --i) {
        var notification = root.activeList.get(i);

        var hasActions = notification.actions?.count > 0;
        var noTimeout = notification.expireTimeout <= 0;

        if (hasActions || noTimeout)
        continue;
        var passed = Date.now() - notification.timestamp;

        if (passed > notification.expireTimeout) {
          root.dismissOrExpireNotification(notification.id, true);
        }
      }
    }
  }
}

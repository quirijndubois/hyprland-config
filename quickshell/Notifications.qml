pragma Singleton
import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    property alias notifications: server.trackedNotifications

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        persistenceSupported: true

        onNotification: n => {
            n.tracked = true
        }
    }
}

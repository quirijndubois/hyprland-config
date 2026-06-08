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
            // Evict oldest once list exceeds 50
            const list = server.trackedNotifications
            if (list.length > 50) {
                const oldest = list[0]
                if (oldest) { oldest.dismiss(); oldest.tracked = false }
            }
        }
    }
}

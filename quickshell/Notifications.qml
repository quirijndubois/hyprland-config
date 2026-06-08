pragma Singleton
import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    // Self-managed history — plain JS objects, so entries survive notification expiry/close.
    // Shape: { id, appName, summary, body, urgency }
    property var history: []
    property int _nextId: 0

    signal newNotification(var entry)

    function dismiss(entryId) {
        root.history = root.history.filter(e => e.id !== entryId)
    }

    function clearAll() {
        root.history = []
    }

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        persistenceSupported: true

        onNotification: function(n) {
            root._nextId++
            const entry = {
                id:      root._nextId,
                appName: n.appName || "",
                summary: n.summary || "",
                body:    n.body    || "",
                urgency: n.urgency
            }
            const next = root.history.concat([entry])
            root.history = next.length > 50 ? next.slice(-50) : next
            root.newNotification(entry)
        }
    }
}

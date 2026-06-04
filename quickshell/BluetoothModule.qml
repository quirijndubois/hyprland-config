import QtQuick
import Quickshell.Io
import Quickshell.Bluetooth

BarText {
    id: root
    color: Theme.teal

    property bool btEnabled: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.enabled : false
    property int connectedCount: 0

    text: {
        if (!btEnabled) return "bt off"
        if (connectedCount > 0) return "bt " + connectedCount
        return "bt on"
    }

    Item {
        width: 0; height: 0

        Repeater {
            id: btRep
            model: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.devices : null
            onCountChanged: root.refreshCount()

            delegate: Item {
                required property var modelData
                width: 0; height: 0
                property bool conn: modelData.connected
                onConnChanged: root.refreshCount()
                Component.onCompleted: root.refreshCount()
            }
        }
    }

    function refreshCount() {
        let c = 0
        for (let i = 0; i < btRep.count; i++) {
            const item = btRep.itemAt(i)
            if (item && item.conn) c++
        }
        connectedCount = c
    }

    MouseArea {
        anchors.fill: parent
        onClicked: bluemanProc.running = true
    }

    Process {
        id: bluemanProc
        command: ["blueman-manager"]
    }
}

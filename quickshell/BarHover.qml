pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    property string activeModule: ""
    property Component popupComponent: null
    property real anchorX: 0
    property real popupH: 104
    property var activeScreen: null

    function show(moduleId, comp, x, h, screen) {
        hideTimer.stop()
        activeModule = moduleId
        popupComponent = comp
        anchorX = x
        popupH = (h > 0) ? h : 104
        activeScreen = screen
    }

    function startHide() { hideTimer.restart() }
    function keepAlive() { hideTimer.stop() }

    Timer {
        id: hideTimer
        interval: 180
        onTriggered: {
            root.activeModule = ""
            root.popupComponent = null
        }
    }
}

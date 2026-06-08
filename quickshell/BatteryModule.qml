import QtQuick
import Quickshell.Services.UPower

BarText {
    id: root
    color: Theme.green

    property var screen: null
    property var device: UPower.displayDevice

    text: {
        if (!device || !device.isPresent) return "bat --%"
        const pct = Math.round(device.percentage)
        const state = device.state
        const prefix = state === 1 ? "+" : state === 4 || state === 5 ? "=" : ""
        return "bat " + prefix + pct + "%"
    }

    property string timeText: {
        if (!device || !device.isPresent) return ""
        const s = device.state
        if (s === 1) {
            const secs = device.timeToFull
            if (secs <= 0 || secs > 86400) return "charging"
            const h = Math.floor(secs / 3600)
            const m = Math.floor((secs % 3600) / 60)
            return h > 0 ? h + "h " + m + "m to full" : m + "m to full"
        }
        const secs = device.timeToEmpty
        if (secs <= 0 || secs > 86400) return ""
        const h = Math.floor(secs / 3600)
        const m = Math.floor((secs % 3600) / 60)
        return h > 0 ? h + "h " + m + "m left" : m + "m left"
    }

    HoverHandler {
        onHoveredChanged: {
            if (hovered)
                BarHover.show("battery", popup, root.mapToItem(null, root.width / 2, 0).x, 0, root.screen)
            else
                BarHover.startHide()
        }
    }

    Component {
        id: popup
        Column {
            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
            spacing: 8

            Row {
                spacing: 8
                Text {
                    text: root.device && root.device.isPresent ? Math.round(root.device.percentage) + "%" : "--%"
                    color: Theme.green
                    font.family: Theme.barFontFamily
                    font.pixelSize: 20
                    font.bold: true
                }
                Text {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 3
                    text: {
                        if (!root.device || !root.device.isPresent) return ""
                        const s = root.device.state
                        return s === 1 ? "charging" : s === 4 || s === 5 ? "full" : "discharging"
                    }
                    color: Theme.subtext
                    font.family: Theme.barFontFamily
                    font.pixelSize: 11
                }
            }

            Rectangle {
                width: parent.width
                height: 5
                radius: 2
                color: Theme.border

                Rectangle {
                    width: parent.parent.width * Math.min(1, (root.device && root.device.isPresent ? root.device.percentage / 100 : 0))
                    height: parent.height
                    radius: parent.radius
                    color: {
                        const pct = root.device ? root.device.percentage : 0
                        return pct < 20 ? Theme.red : pct < 40 ? Theme.yellow : Theme.green
                    }
                    Behavior on width { NumberAnimation { duration: 400 } }
                }
            }

            Text {
                text: root.timeText
                color: Theme.subtext
                font.family: Theme.barFontFamily
                font.pixelSize: 11
                visible: root.timeText !== ""
            }
        }
    }
}

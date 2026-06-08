import QtQuick
import Quickshell.Io

BarText {
    id: root
    color: Theme.blue

    property var screen: null
    property int cpuUsage: 0
    property var prevStat: null
    property var history: []
    property var topProcs: []

    text: "cpu " + cpuUsage + "%"

    onCpuUsageChanged: {
        const h = history.slice()
        h.push(cpuUsage)
        if (h.length > 24) h.shift()
        history = h
    }

    Process {
        id: statProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(/\s+/)
                const vals = parts.slice(1).map(v => parseInt(v) || 0)
                const idle = vals[3] + (vals[4] || 0)
                const total = vals.reduce((a, b) => a + b, 0)
                if (root.prevStat) {
                    const dTotal = total - root.prevStat.total
                    const dIdle = idle - root.prevStat.idle
                    root.cpuUsage = dTotal > 0 ? Math.round((dTotal - dIdle) / dTotal * 100) : 0
                }
                root.prevStat = { idle, total }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: statProc.running = true
    }

    Process {
        id: topProc
        command: ["sh", "-c",
            "ps --no-headers -eo comm,pcpu --sort=-pcpu 2>/dev/null | head -10 | " +
            "awk '$2+0>0 && $1!~/^\\[/ { n=$1; sub(/.*\\//, \"\", n); sub(/:.*/, \"\", n); printf \"%s\\t%.1f\\n\", n, $2 }' | head -5"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.topProcs = this.text.trim().split("\n")
                    .filter(l => l.length > 0)
                    .map(l => { const p = l.split("\t"); return { name: p[0] || "", value: p[1] || "0" } })
            }
        }
    }

    Connections {
        target: BarHover
        function onActiveModuleChanged() {
            if (BarHover.activeModule === "cpu") topProc.running = true
        }
    }

    Timer {
        interval: 3000
        running: BarHover.activeModule === "cpu"
        repeat: true
        onTriggered: if (!topProc.running) topProc.running = true
    }

    HoverHandler {
        onHoveredChanged: {
            if (hovered)
                BarHover.show("cpu", popup, root.mapToItem(null, root.width / 2, 0).x, 220, root.screen)
            else
                BarHover.startHide()
        }
    }

    Component {
        id: popup
        Column {
            anchors { left: parent.left; right: parent.right; top: parent.top }
            spacing: 6

            Text {
                text: root.cpuUsage + "%"
                color: Theme.blue
                font.family: Theme.barFontFamily
                font.pixelSize: 20
                font.bold: true
            }

            Rectangle {
                width: parent.width
                height: 5
                radius: 2
                color: Theme.border
                Rectangle {
                    width: parent.parent.width * (root.cpuUsage / 100)
                    height: parent.height; radius: parent.radius
                    color: root.cpuUsage > 80 ? Theme.red : root.cpuUsage > 50 ? Theme.yellow : Theme.blue
                    Behavior on width { NumberAnimation { duration: 300 } }
                }
            }

            Row {
                spacing: 2
                Repeater {
                    model: root.history
                    Rectangle {
                        required property var modelData
                        width: 5; height: 14; color: Theme.border; radius: 1
                        Rectangle {
                            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                            height: Math.max(2, parent.height * modelData / 100)
                            color: modelData > 80 ? Theme.red : modelData > 50 ? Theme.yellow : Theme.blue
                            radius: 1
                        }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Theme.border; opacity: 0.5 }

            Text {
                text: "top processes"
                color: Theme.subtext
                font.family: Theme.barFontFamily
                font.pixelSize: 10
            }

            Column {
                width: parent.width
                spacing: 3
                Repeater {
                    model: root.topProcs
                    Row {
                        required property var modelData
                        width: parent.width
                        Text {
                            width: parent.width - valText.width
                            text: modelData.name
                            color: Theme.text
                            font.family: Theme.barFontFamily
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                        Text {
                            id: valText
                            text: modelData.value + "%"
                            color: Theme.blue
                            font.family: Theme.barFontFamily
                            font.pixelSize: 11
                        }
                    }
                }
            }
        }
    }
}

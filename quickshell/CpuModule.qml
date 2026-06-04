import QtQuick
import Quickshell.Io

BarText {
    id: root
    color: Theme.blue

    property int cpuUsage: 0
    property var prevStat: null
    text: "cpu " + cpuUsage + "%"

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
}

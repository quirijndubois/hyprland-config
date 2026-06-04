import QtQuick
import Quickshell.Io

BarText {
    id: root
    color: Theme.red

    property int memUsage: 0
    text: "mem " + memUsage + "%"

    Process {
        id: memProc
        command: ["sh", "-c", "awk '/MemTotal:/{t=$2} /MemAvailable:/{a=$2} END{print t,a}' /proc/meminfo"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(" ")
                const total = parseInt(parts[0]) || 0
                const avail = parseInt(parts[1]) || 0
                root.memUsage = total > 0 ? Math.round((total - avail) / total * 100) : 0
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: memProc.running = true
    }
}

import QtQuick
import Quickshell.Io

BarText {
    id: root
    color: Theme.blue

    property int gpuUsage: 0
    text: "gpu " + gpuUsage + "%"

    Process {
        id: gpuProc
        command: ["sh", "-c", "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null || echo 0"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const val = parseInt(this.text.trim()) || 0
                root.gpuUsage = Math.min(100, Math.max(0, val))
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: gpuProc.running = true
    }
}

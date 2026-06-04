import QtQuick
import Quickshell.Io

BarText {
    id: root
    color: Theme.purple

    property string netText: "net --"
    text: netText

    Process {
        id: netProc
        command: ["sh", "-c",
            "SSID=$(iwgetid -r 2>/dev/null | head -c 9); " +
            "if [ -n \"$SSID\" ]; then echo \"wifi $SSID\"; " +
            "elif nmcli dev 2>/dev/null | grep -q 'ethernet.*connected'; then echo 'eth'; " +
            "else echo 'disc'; fi"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const out = this.text.trim()
                if (out.startsWith("wifi ")) {
                    root.netText = out.slice(5)
                } else if (out === "eth") {
                    root.netText = "eth"
                } else {
                    root.netText = "no net"
                }
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: netProc.running = true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: nmEditor.running = true
    }

    Process {
        id: nmEditor
        command: ["nm-connection-editor"]
    }
}

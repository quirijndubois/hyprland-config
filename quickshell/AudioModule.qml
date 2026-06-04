import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire

BarText {
    id: root
    color: Theme.yellow

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property var sink: Pipewire.defaultAudioSink

    text: {
        if (!sink || !sink.audio) return "vol --%"
        const vol = Math.round(sink.audio.volume * 100)
        return sink.audio.muted ? "vol mute" : "vol " + vol + "%"
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                pavuProc.running = true
            } else if (root.sink && root.sink.audio) {
                root.sink.audio.muted = !root.sink.audio.muted
            }
        }
    }

    Process {
        id: pavuProc
        command: ["pavucontrol"]
    }
}

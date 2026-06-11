import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

Item {
    id: root
    visible: false

    property string username: ""
    signal lockReleased()

    function lock() {
        wlLock.locked = true
    }

    Process {
        command: ["sh", "-c", "id -un"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.username = this.text.trim()
        }
    }

    WlSessionLock {
        id: wlLock
        onLockedChanged: if (!locked) root.lockReleased()

        surface: Component {
            WlSessionLockSurface {
                id: surface
                color: Theme.base

                property string passwordInput: ""
                property bool   authFailed:    false
                property bool   authRunning:   false
                property string timeStr: Qt.formatTime(new Date(), "hh:mm")
                property string dateStr: Qt.formatDate(new Date(), "dddd, MMMM d")

                Timer {
                    interval: 1000
                    running: true; repeat: true
                    onTriggered: {
                        surface.timeStr = Qt.formatTime(new Date(), "hh:mm")
                        surface.dateStr = Qt.formatDate(new Date(), "dddd, MMMM d")
                    }
                }

                Timer {
                    id: failTimer
                    interval: 800
                    onTriggered: surface.authFailed = false
                }

                Process {
                    id: authProc
                    stdinEnabled: true
                    stdout: StdioCollector {}
                    stderr: StdioCollector {}
                    onStarted: write(surface.passwordInput + "\n")
                    onExited: function(exitCode, exitStatus) {
                        if (exitCode === 0) {
                            exitAnim.start()
                        } else {
                            surface.authFailed = true
                            surface.passwordInput = ""
                            failTimer.restart()
                        }
                        surface.authRunning = false
                    }
                }

                function authenticate() {
                    if (surface.authRunning || surface.passwordInput.length === 0) return
                    surface.authRunning = true
                    authProc.command = [
                        "sh", "-c",
                        "IFS= read -r pw && printf '%s\\000' \"$pw\" | /usr/bin/unix_chkpwd \"$1\" nullok",
                        "--", root.username
                    ]
                    authProc.running = false
                    authProc.running = true
                }

                Item {
                    anchors.fill: parent
                    focus: true
                    Component.onCompleted: forceActiveFocus()

                    Keys.onPressed: event => {
                        if (surface.authRunning) { event.accepted = true; return }
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            surface.authenticate()
                        } else if (event.key === Qt.Key_Backspace) {
                            if (event.modifiers & Qt.ControlModifier)
                                surface.passwordInput = ""
                            else
                                surface.passwordInput = surface.passwordInput.slice(0, -1)
                        } else if (event.key === Qt.Key_Escape) {
                            surface.passwordInput = ""
                        } else if (event.text && event.text.charCodeAt(0) >= 32) {
                            surface.passwordInput += event.text
                            surface.authFailed = false
                        }
                        event.accepted = true
                    }

                    Rectangle { anchors.fill: parent; color: Theme.base }

                    Column {
                        id: contentCol
                        anchors.centerIn: parent
                        spacing: 0

                        opacity: 0
                        transform: Translate { id: contentSlide; y: 50 }
                        Component.onCompleted: enterAnim.start()

                        SequentialAnimation {
                            id: enterAnim
                            ParallelAnimation {
                                NumberAnimation {
                                    target: contentSlide; property: "y"
                                    from: 50; to: 0
                                    duration: 420; easing.type: Easing.OutExpo
                                }
                                NumberAnimation {
                                    target: contentCol; property: "opacity"
                                    from: 0; to: 1
                                    duration: 340; easing.type: Easing.OutCubic
                                }
                            }
                        }

                        SequentialAnimation {
                            id: exitAnim
                            ParallelAnimation {
                                NumberAnimation {
                                    target: contentSlide; property: "y"
                                    to: -60; duration: 260; easing.type: Easing.InCubic
                                }
                                NumberAnimation {
                                    target: contentCol; property: "opacity"
                                    to: 0; duration: 200; easing.type: Easing.InCubic
                                }
                            }
                            ScriptAction { script: wlLock.locked = false }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: surface.timeStr
                            color: Theme.text
                            font.family: "JetBrains Mono"
                            font.pixelSize: 96; font.bold: true
                        }

                        Item { width: 1; height: 4 }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: surface.dateStr
                            color: Theme.subtext
                            font.family: "JetBrains Mono"; font.pixelSize: 18
                        }

                        Item { width: 1; height: 4 }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 280; height: 1
                            color: Theme.border; opacity: 0.5
                        }

                        Item { width: 1; height: 44 }

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 8

                            Text {
                                text: ""
                                color: Theme.purple
                                font.family: "Symbols Nerd Font Mono"; font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: root.username
                                color: Theme.purple
                                font.family: "JetBrains Mono"; font.pixelSize: 14; font.bold: true
                                verticalAlignment: Text.AlignVCenter
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Item { width: 1; height: 14 }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 280; height: 42; radius: 6
                            color: Theme.surface
                            border.width: 1
                            border.color: surface.authFailed  ? Theme.red
                                        : surface.authRunning ? Theme.yellow
                                        : Theme.border
                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                visible: !surface.authFailed && !surface.authRunning && surface.passwordInput.length === 0
                                text: "enter password"
                                color: Theme.subtext
                                font.family: "JetBrains Mono"; font.pixelSize: 12
                            }

                            Row {
                                anchors.centerIn: parent; spacing: 8
                                visible: !surface.authFailed && !surface.authRunning && surface.passwordInput.length > 0
                                Repeater {
                                    model: Math.min(surface.passwordInput.length, 28)
                                    delegate: Rectangle {
                                        width: 6; height: 6; radius: 3; color: Theme.blue
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            Text {
                                anchors.centerIn: parent; visible: surface.authFailed
                                text: "incorrect password"; color: Theme.red
                                font.family: "JetBrains Mono"; font.pixelSize: 12
                            }

                            Text {
                                anchors.centerIn: parent; visible: surface.authRunning
                                text: "authenticating..."; color: Theme.yellow
                                font.family: "JetBrains Mono"; font.pixelSize: 12
                            }
                        }
                    }
                }
            }
        }
    }
}

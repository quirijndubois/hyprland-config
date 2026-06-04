//@ pragma UseQApplication
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

ShellRoot {
    id: root

    property bool settingsOpen: false

    IpcHandler {
        target: "settings"

        function toggle() { root.settingsOpen = !root.settingsOpen }
        function open()   { root.settingsOpen = true }
        function close()  { root.settingsOpen = false }
    }

    // Ensure awww-daemon is running for wallpaper changes
    Process {
        command: ["awww-daemon"]
        running: true
    }

    SettingsWindow {
        visible: root.settingsOpen
        onCloseRequested: root.settingsOpen = false
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                required property var modelData
                screen: modelData

                anchors { top: true; left: true; right: true }
                implicitHeight: 30
                color: "transparent"
                exclusiveZone: implicitHeight

                property var hyprMonitor: Hyprland.monitorFor(modelData)

                Rectangle {
                    anchors.fill: parent
                    color: Theme.base

                    // Bottom border
                    Rectangle {
                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                        height: 1
                        color: Theme.border
                    }

                    Row {
                        id: leftRow
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin: 16
                        }
                        spacing: 0

                        BarText {
                            text: "menu"
                            color: root.settingsOpen ? Theme.purple : Theme.subtext
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.settingsOpen = !root.settingsOpen
                            }
                        }
                        Separator {}
                        ClockModule {}
                        Separator {}
                        BatteryModule {}
                        Separator {}
                        CpuModule {}
                        Separator {}
                        MemoryModule {}
                    }

                    Row {
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 0

                        WorkspacesModule { monitor: hyprMonitor }
                    }

                    Row {
                        id: rightRow
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 16
                        }
                        spacing: 0

                        AudioModule {}
                        Separator {}
                        BluetoothModule {}
                        Separator {}
                        NetworkModule {}
                        Separator { visible: trayMod.visible }
                        TrayModule { id: trayMod }
                    }
                }
            }
        }
    }
}

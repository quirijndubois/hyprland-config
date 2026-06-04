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
                implicitHeight: Theme.barHeight
                color: "transparent"
                exclusiveZone: implicitHeight

                property var hyprMonitor: Hyprland.monitorFor(modelData)

                Rectangle {
                    anchors.fill: parent
                    color: Theme.design === "islands" ? "transparent" : Theme.base

                    // Bottom border — hidden in islands mode
                    Rectangle {
                        visible: Theme.design !== "islands"
                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                        height: 1
                        color: Theme.border
                    }

                    // ── Left island background ─────────────────
                    Rectangle {
                        visible: Theme.design === "islands"
                        anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                        width: leftRow.implicitWidth + 24
                        height: parent.height - 8
                        color: Theme.surface
                        radius: 8
                        border.color: Theme.border
                        border.width: 1
                    }

                    Row {
                        id: leftRow
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin: Theme.design === "islands" ? 20 : 16
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

                    // ── Center island background ───────────────
                    Rectangle {
                        visible: Theme.design === "islands"
                        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
                        width: centerRow.implicitWidth + 24
                        height: parent.height - 8
                        color: Theme.surface
                        radius: 8
                        border.color: Theme.border
                        border.width: 1
                    }

                    Row {
                        id: centerRow
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 0

                        WorkspacesModule { monitor: hyprMonitor }
                    }

                    // ── Right island background ────────────────
                    Rectangle {
                        visible: Theme.design === "islands"
                        anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                        width: rightRow.implicitWidth + 24
                        height: parent.height - 8
                        color: Theme.surface
                        radius: 8
                        border.color: Theme.border
                        border.width: 1
                    }

                    Row {
                        id: rightRow
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: Theme.design === "islands" ? 20 : 16
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

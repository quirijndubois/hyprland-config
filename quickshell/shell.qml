//@ pragma UseQApplication
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

ShellRoot {
    id: root

    property bool settingsOpen: false
    property string requestedPage: "main"

    IpcHandler {
        target: "settings"

        function toggle() { root.settingsOpen = !root.settingsOpen }
        function open()   { root.settingsOpen = true }
        function close()  { root.settingsOpen = false }
    }

    IpcHandler {
        target: "settings-apps"

        function open() { root.requestedPage = "apps"; root.settingsOpen = true }
    }

    // Ensure awww-daemon is running for wallpaper changes
    Process {
        command: ["awww-daemon"]
        running: true
    }

    SettingsWindow {
        visible: root.settingsOpen
        requestedPage: root.requestedPage
        onCloseRequested: { root.requestedPage = "main"; root.settingsOpen = false }
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
                    color: (Theme.design === "islands" || Theme.design === "pills") ? "transparent" : Theme.base

                    // Bottom border — hidden in islands/pills mode
                    Rectangle {
                        visible: Theme.design !== "islands" && Theme.design !== "pills"
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
                            leftMargin: Theme.design === "islands" ? 20 : Theme.design === "pills" ? 8 : 16
                        }
                        spacing: Theme.design === "pills" ? 4 : 0

                        BarText {
                            text: "menu"
                            visible: Theme.showMenu
                            color: root.settingsOpen ? Theme.purple : Theme.subtext
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.settingsOpen = !root.settingsOpen
                            }
                        }
                        Separator { visible: Theme.showClock && Theme.design !== "pills" }
                        ClockModule { visible: Theme.showClock }
                        Separator { visible: Theme.showBattery && Theme.design !== "pills" }
                        BatteryModule { visible: Theme.showBattery }
                        Separator { visible: Theme.showCpu && Theme.design !== "pills" }
                        CpuModule { visible: Theme.showCpu }
                        Separator { visible: Theme.showMemory && Theme.design !== "pills" }
                        MemoryModule { visible: Theme.showMemory }
                        Separator { visible: Theme.showGpu && Theme.design !== "pills" }
                        GpuModule { visible: Theme.showGpu }
                    }

                    // ── Center island / pill background ───────────────
                    Rectangle {
                        visible: Theme.design === "islands" || Theme.design === "pills"
                        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
                        width: centerRow.implicitWidth + 24
                        height: Theme.design === "pills" ? Theme.barHeight - 8 : parent.height - 8
                        color: Theme.surface
                        radius: Theme.design === "pills" ? (Theme.barHeight - 8) / 2 : 8
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

                        WorkspacesModule { monitor: hyprMonitor; visible: Theme.showWorkspaces }
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
                            rightMargin: Theme.design === "islands" ? 20 : Theme.design === "pills" ? 8 : 16
                        }
                        spacing: Theme.design === "pills" ? 4 : 0

                        AudioModule { visible: Theme.showAudio }
                        Separator { visible: Theme.showBluetooth && Theme.design !== "pills" }
                        BluetoothModule { visible: Theme.showBluetooth }
                        Separator { visible: Theme.showNetwork && Theme.design !== "pills" }
                        NetworkModule { visible: Theme.showNetwork }
                        Separator { visible: trayMod.visible && Theme.design !== "pills" }
                        TrayModule { id: trayMod }
                    }
                }
            }
        }
    }
}

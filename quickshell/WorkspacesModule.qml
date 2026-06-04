import QtQuick
import Quickshell.Hyprland

Row {
    id: root
    spacing: 8
    property var monitor: null

    Repeater {
        model: Hyprland.workspaces

        delegate: Text {
            required property var modelData

            property bool focused: modelData.focused
            visible: !root.monitor || modelData.monitor === root.monitor

            text: focused ? "[" + modelData.name + "]" : modelData.name
            color: focused ? Theme.blue : Theme.subtext
            font.family: "JetBrains Mono"
            font.bold: focused
            font.pixelSize: 13
            verticalAlignment: Text.AlignVCenter

            MouseArea {
                anchors.fill: parent
                onClicked: modelData.activate()
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
}

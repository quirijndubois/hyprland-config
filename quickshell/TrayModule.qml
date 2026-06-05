import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Item {
    id: root
    visible: trayRepeater.count > 0 && Theme.showTray

    implicitWidth: innerRow.implicitWidth + (Theme.design === "pills" ? 20 : 0)
    implicitHeight: Theme.design === "pills" ? Theme.barHeight - 8 : innerRow.implicitHeight

    Rectangle {
        visible: Theme.design === "pills"
        anchors.centerIn: parent
        width: innerRow.implicitWidth + 20
        height: root.implicitHeight
        radius: height / 2
        color: Theme.surface
        border.color: Theme.border
        border.width: 1
    }

    Row {
        id: innerRow
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            id: trayRepeater
            model: SystemTray.items

            delegate: Item {
                required property var modelData
                width: 16
                height: 16

                Image {
                    anchors.fill: parent
                    source: {
                        const icon = modelData.icon
                        if (!icon) return ""
                        if (icon.startsWith("/") || icon.startsWith("file://")) return icon.startsWith("/") ? "file://" + icon : icon
                        return Quickshell.iconPath(icon, "application-x-executable")
                    }
                    sourceSize: Qt.size(16, 16)
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                }

                QsMenuAnchor {
                    id: menuAnchor
                    anchor.item: parent
                    menu: modelData.menu
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton && modelData.hasMenu) {
                            menuAnchor.open()
                        } else {
                            modelData.activate()
                        }
                    }
                }
            }
        }
    }
}

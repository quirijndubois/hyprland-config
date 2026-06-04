import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Row {
    id: root
    spacing: 8
    visible: trayRepeater.count > 0

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
                    if (icon.startsWith("/")) return "file://" + icon
                    return Quickshell.iconPath(icon, true)
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

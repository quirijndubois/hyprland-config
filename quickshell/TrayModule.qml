import QtQuick
import Quickshell
import Quickshell.Widgets
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

            IconImage {
                anchors.fill: parent
                source: modelData.icon
                implicitSize: 16
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

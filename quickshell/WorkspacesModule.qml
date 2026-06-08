import QtQuick
import Quickshell.Hyprland
import Quickshell.Services.Notifications

Row {
    id: root
    spacing: 8
    property var monitor: null
    property var screen: null

    Repeater {
        model: Hyprland.workspaces

        delegate: Text {
            required property var modelData

            property bool focused: modelData.focused
            visible: !root.monitor || modelData.monitor === root.monitor

            text: focused ? "[" + modelData.name + "]" : modelData.name
            color: focused ? Theme.blue : Theme.subtext
            font.family: Theme.barFontFamily
            font.bold: focused || Theme.barFontBold
            font.pixelSize: Theme.barFontSize
            verticalAlignment: Text.AlignVCenter

            MouseArea {
                anchors.fill: parent
                onClicked: modelData.activate()
                cursorShape: Qt.PointingHandCursor
            }
        }
    }

    HoverHandler {
        onHoveredChanged: {
            if (hovered) {
                const count = Math.min(Notifications.history.length, 5)
                const h = count === 0 ? 64 : 44 + count * 50 + 22
                BarHover.show("workspaces", notifPopup, root.mapToItem(null, root.width / 2, 0).x, h, root.screen)
            } else {
                BarHover.startHide()
            }
        }
    }

    Component {
        id: notifPopup
        Column {
            anchors { left: parent.left; right: parent.right; top: parent.top }
            spacing: 6

            Item {
                width: parent.width
                height: 16

                Text {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    text: "notifications"
                    color: Theme.purple
                    font.family: Theme.barFontFamily
                    font.pixelSize: 12
                    font.bold: true
                }

                Text {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    text: Notifications.history.length > 0
                        ? Notifications.history.length + " total" : ""
                    color: Theme.subtext
                    font.family: Theme.barFontFamily
                    font.pixelSize: 10
                }
            }

            Rectangle { width: parent.width; height: 1; color: Theme.border; opacity: 0.5 }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: Notifications.history.length === 0
                text: "no notifications"
                color: Theme.subtext
                font.family: Theme.barFontFamily
                font.pixelSize: 11
            }

            Column {
                visible: Notifications.history.length > 0
                width: parent.width
                spacing: 4

                Repeater {
                    id: popupNotifRep
                    model: Notifications.history

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        // Show only the 5 most recent; invisible items are excluded from Column layout
                        visible: index >= Notifications.history.length - 5
                        width: parent.width
                        height: notifItemCol.implicitHeight + 12
                        radius: 4
                        color: Theme.base

                        Rectangle {
                            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                            width: 2; radius: 1
                            color: modelData.urgency === NotificationUrgency.Critical ? Theme.red
                                 : modelData.urgency === NotificationUrgency.Low      ? Theme.subtext
                                 : Theme.blue
                        }

                        Column {
                            id: notifItemCol
                            anchors {
                                left: parent.left; leftMargin: 8
                                right: popupDismiss.left; rightMargin: 4
                                top: parent.top; topMargin: 6
                            }
                            spacing: 2

                            Text {
                                width: parent.width
                                text: modelData.appName || ""
                                color: modelData.urgency === NotificationUrgency.Critical ? Theme.red
                                     : modelData.urgency === NotificationUrgency.Low      ? Theme.subtext
                                     : Theme.blue
                                font.family: Theme.barFontFamily
                                font.pixelSize: 9
                                elide: Text.ElideRight
                            }

                            Text {
                                width: parent.width
                                visible: text !== ""
                                text: modelData.summary || ""
                                color: Theme.text
                                font.family: Theme.barFontFamily
                                font.pixelSize: 11
                                font.bold: true
                                elide: Text.ElideRight
                            }
                        }

                        Text {
                            id: popupDismiss
                            anchors { right: parent.right; rightMargin: 6; verticalCenter: parent.verticalCenter }
                            text: "×"
                            color: Theme.subtext
                            font.family: Theme.barFontFamily
                            font.pixelSize: 12
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Notifications.dismiss(modelData.id)
                            }
                        }
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: Notifications.history.length > 0
                text: "clear all"
                color: Theme.red
                font.family: Theme.barFontFamily
                font.pixelSize: 10
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Notifications.clearAll()
                }
            }
        }
    }
}

import QtQuick

BarText {
    id: root

    property string timeStr: Qt.formatTime(new Date(), "hh:mm")
    text: timeStr

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.timeStr = Qt.formatTime(new Date(), "hh:mm")
    }
}

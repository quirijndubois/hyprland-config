import Quickshell
import Quickshell.Io
import QtQuick

FloatingWindow {
    id: root
    implicitWidth: 520
    implicitHeight: 420
    color: Theme.base
    title: "Quickshell Settings"

    signal closeRequested()

    property string page: "main"
    property string activeSubPage: "wallpaper"
    property int selectedIndex: 0
    property string searchQuery: ""
    property int selectedSearchIndex: 0
    property var wallpaperFiles: []
    readonly property string wallpapersDir: "/home/q/dev/hyprland-config/wallpapers/"

    onPageChanged: {
        if (page !== "main") activeSubPage = page
    }

    onSearchQueryChanged: {
        selectedSearchIndex = 0
    }

    function fuzzyMatch(query, str) {
        query = query.toLowerCase()
        str = str.toLowerCase()
        let qi = 0
        for (let i = 0; i < str.length && qi < query.length; i++) {
            if (str[i] === query[qi]) qi++
        }
        return qi === query.length
    }

    property var searchResults: {
        if (!searchQuery) return []
        const results = []
        for (const f of wallpaperFiles) {
            const name = f.replace(/\.[^.]+$/, "")
            if (root.fuzzyMatch(searchQuery, name))
                results.push({ type: "wallpaper", label: name, file: f })
        }
        for (const p of paletteOptions) {
            if (root.fuzzyMatch(searchQuery, p.label) || root.fuzzyMatch(searchQuery, p.id))
                results.push({ type: "palette", label: p.label, id: p.id, swatches: p.swatches })
        }
        return results
    }

    readonly property var paletteOptions: [
        { id: "mocha",       label: "catppuccin mocha",      swatches: ["#89b4fa","#a6e3a1","#f38ba8","#f9e2af","#94e2d5","#cba6f7"] },
        { id: "macchiato",   label: "catppuccin macchiato",  swatches: ["#8aadf4","#a6da95","#ed8796","#eed49f","#8bd5ca","#c6a0f6"] },
        { id: "frappe",      label: "catppuccin frappe",     swatches: ["#8caaee","#a6d189","#e78284","#e5c890","#81c8be","#ca9ee6"] },
        { id: "latte",       label: "catppuccin latte",      swatches: ["#1e66f5","#40a02b","#d20f39","#df8e1d","#179299","#8839ef"] },
        { id: "tokyo-night", label: "tokyo night",           swatches: ["#7aa2f7","#9ece6a","#f7768e","#e0af68","#73daca","#bb9af7"] },
        { id: "gruvbox",     label: "gruvbox",               swatches: ["#83a598","#b8bb26","#fb4934","#fabd2f","#8ec07c","#d3869b"] },
    ]

    readonly property var mainItems: [
        { id: "wallpaper", label: "wallpaper" },
        { id: "palette",   label: "palette" },
    ]

    onVisibleChanged: {
        if (visible) {
            page = "main"
            selectedIndex = 0
            searchQuery = ""
            Qt.callLater(() => keyNav.forceActiveFocus())
        }
    }

    Process {
        id: listProc
        command: ["sh", "-c", "ls \"" + root.wallpapersDir + "\""]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.wallpaperFiles = this.text.trim().split("\n").filter(f => f.length > 0)
            }
        }
    }

    Process {
        id: awwwProc
        stdout: StdioCollector {}
        stderr: StdioCollector {}
    }

    property string pendingWallpaper: ""

    function applyWallpaper(filename) {
        if (awwwProc.running) {
            pendingWallpaper = filename
        } else {
            pendingWallpaper = ""
            awwwProc.command = [
                "awww", "img",
                "--transition-type", "center",
                "--transition-duration", "1.5",
                "--transition-fps", "60",
                root.wallpapersDir + filename
            ]
            awwwProc.running = true
        }
    }

    Connections {
        target: awwwProc
        function onRunningChanged() {
            if (!awwwProc.running && root.pendingWallpaper !== "") {
                const next = root.pendingWallpaper
                root.pendingWallpaper = ""
                root.applyWallpaper(next)
            }
        }
    }

    Item {
        id: keyNav
        anchors.fill: parent
        clip: true
        focus: true

        // 0 = main, 1 = sub-page (drives slide animation)
        property real offset: root.page !== "main" ? 1.0 : 0.0
        Behavior on offset {
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }

        // Search overlay fade
        property real searchOpacity: root.searchQuery !== "" ? 1.0 : 0.0
        Behavior on searchOpacity {
            NumberAnimation { duration: 140; easing.type: Easing.InOutQuad }
        }

        Keys.onPressed: event => {
            const inSearch = root.searchQuery !== ""

            if (event.key === Qt.Key_Escape) {
                if (inSearch) {
                    root.searchQuery = ""
                } else if (root.page === "main") {
                    root.closeRequested()
                } else {
                    root.page = "main"
                    root.selectedIndex = 0
                }
                event.accepted = true
                return
            }

            if (event.key === Qt.Key_Backspace && inSearch) {
                root.searchQuery = root.searchQuery.slice(0, -1)
                event.accepted = true
                return
            }

            if (event.key === Qt.Key_Up) {
                if (inSearch) {
                    if (root.selectedSearchIndex > 0) {
                        root.selectedSearchIndex--
                        searchList.positionViewAtIndex(root.selectedSearchIndex, ListView.Contain)
                    }
                } else if (root.selectedIndex > 0) {
                    root.selectedIndex--
                    if (root.page === "wallpaper")
                        wpList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                    else if (root.page === "palette")
                        paletteList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                }
                event.accepted = true
                return
            }

            if (event.key === Qt.Key_Down) {
                if (inSearch) {
                    if (root.selectedSearchIndex < root.searchResults.length - 1) {
                        root.selectedSearchIndex++
                        searchList.positionViewAtIndex(root.selectedSearchIndex, ListView.Contain)
                    }
                } else {
                    const maxIdx = root.page === "main"     ? root.mainItems.length - 1
                                 : root.page === "wallpaper" ? Math.max(0, root.wallpaperFiles.length - 1)
                                 : root.paletteOptions.length - 1
                    if (root.selectedIndex < maxIdx) {
                        root.selectedIndex++
                        if (root.page === "wallpaper")
                            wpList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                        else if (root.page === "palette")
                            paletteList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                    }
                }
                event.accepted = true
                return
            }

            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (inSearch) {
                    activateSearchItem()
                } else {
                    activateItem()
                }
                event.accepted = true
                return
            }

            // Capture printable characters to build search query
            if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32) {
                root.searchQuery += event.text
                event.accepted = true
            }
        }

        function activateItem() {
            if (root.page === "main") {
                const item = root.mainItems[root.selectedIndex]
                if (item) { root.page = item.id; root.selectedIndex = 0 }
            } else if (root.page === "wallpaper" && root.wallpaperFiles.length > 0) {
                root.applyWallpaper(root.wallpaperFiles[root.selectedIndex])
            } else if (root.page === "palette") {
                Theme.name = root.paletteOptions[root.selectedIndex].id
            }
        }

        function activateSearchItem() {
            const result = root.searchResults[root.selectedSearchIndex]
            if (!result) return
            if (result.type === "wallpaper") root.applyWallpaper(result.file)
            else if (result.type === "palette") Theme.name = result.id
            root.searchQuery = ""
        }

        // ── Main page — slides left on navigate ────────────────
        Item {
            width: parent.width
            height: parent.height
            x: -parent.width * keyNav.offset

            Rectangle {
                id: mainHeader
                width: parent.width
                height: 44
                color: Theme.surface

                Text {
                    anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                    text: "settings"
                    color: Theme.purple
                    font.family: "JetBrains Mono"
                    font.pixelSize: 14
                    font.bold: true
                }
            }

            Rectangle { anchors.top: mainHeader.bottom; width: parent.width; height: 1; color: Theme.border }

            ListView {
                id: mainList
                anchors { left: parent.left; right: parent.right; top: mainHeader.bottom; topMargin: 1 }
                height: contentHeight
                model: root.mainItems
                interactive: false

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    width: mainList.width
                    height: 44
                    color: root.selectedIndex === index ? Theme.border : "transparent"

                    Row {
                        anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                        spacing: 14

                        Text {
                            text: root.selectedIndex === index ? ">" : " "
                            color: Theme.blue
                            font.family: "JetBrains Mono"
                            font.pixelSize: 13
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            text: modelData.label
                            color: root.selectedIndex === index ? Theme.text : Theme.subtext
                            font.family: "JetBrains Mono"
                            font.pixelSize: 13
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Text {
                        anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                        text: ">"
                        color: Theme.subtext
                        font.family: "JetBrains Mono"
                        font.pixelSize: 12
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onEntered: root.selectedIndex = index
                        onClicked: keyNav.activateItem()
                    }
                }
            }
        }

        // ── Sub-page container — slides in from right ──────────
        Item {
            width: parent.width
            height: parent.height
            x: parent.width * (1.0 - keyNav.offset)

            // ── Wallpaper ──────────────────────────────────────
            Item {
                anchors.fill: parent
                visible: root.activeSubPage === "wallpaper"

                Rectangle {
                    id: wpHeader
                    width: parent.width
                    height: 44
                    color: Theme.surface

                    Row {
                        anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                        spacing: 14

                        Text {
                            text: "< back"
                            color: Theme.subtext
                            font.family: "JetBrains Mono"
                            font.pixelSize: 12
                            verticalAlignment: Text.AlignVCenter
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { root.page = "main"; root.selectedIndex = 0 }
                            }
                        }

                        Text {
                            text: "wallpaper"
                            color: Theme.purple
                            font.family: "JetBrains Mono"
                            font.pixelSize: 14
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Rectangle { id: wpDivider; anchors.top: wpHeader.bottom; width: parent.width; height: 1; color: Theme.border }

                Text {
                    anchors.centerIn: parent
                    visible: root.wallpaperFiles.length === 0
                    text: "loading..."
                    color: Theme.subtext
                    font.family: "JetBrains Mono"
                    font.pixelSize: 13
                }

                ListView {
                    id: wpList
                    anchors { left: parent.left; right: parent.right; top: wpDivider.bottom; bottom: parent.bottom }
                    model: root.wallpaperFiles
                    clip: true
                    visible: root.wallpaperFiles.length > 0

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width: wpList.width
                        height: 56
                        color: root.selectedIndex === index ? Theme.border : "transparent"

                        Row {
                            anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                            spacing: 14

                            Text {
                                text: root.selectedIndex === index ? ">" : " "
                                color: Theme.blue
                                font.family: "JetBrains Mono"
                                font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                            }

                            Text {
                                text: modelData.replace(/\.[^.]+$/, "")
                                color: root.selectedIndex === index ? Theme.text : Theme.subtext
                                font.family: "JetBrains Mono"
                                font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Rectangle {
                            anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                            width: 80
                            height: 45
                            radius: 4
                            color: Theme.surface
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: "file://" + root.wallpapersDir + modelData
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                smooth: true
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onEntered: root.selectedIndex = index
                            onClicked: keyNav.activateItem()
                        }
                    }
                }
            }

            // ── Palette ────────────────────────────────────────
            Item {
                anchors.fill: parent
                visible: root.activeSubPage === "palette"

                Rectangle {
                    id: paletteHeader
                    width: parent.width
                    height: 44
                    color: Theme.surface

                    Row {
                        anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                        spacing: 14

                        Text {
                            text: "< back"
                            color: Theme.subtext
                            font.family: "JetBrains Mono"
                            font.pixelSize: 12
                            verticalAlignment: Text.AlignVCenter
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { root.page = "main"; root.selectedIndex = 0 }
                            }
                        }

                        Text {
                            text: "palette"
                            color: Theme.purple
                            font.family: "JetBrains Mono"
                            font.pixelSize: 14
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Rectangle { id: paletteDivider; anchors.top: paletteHeader.bottom; width: parent.width; height: 1; color: Theme.border }

                ListView {
                    id: paletteList
                    anchors { left: parent.left; right: parent.right; top: paletteDivider.bottom; bottom: parent.bottom }
                    model: root.paletteOptions
                    clip: true
                    interactive: false

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width: paletteList.width
                        height: 40
                        color: root.selectedIndex === index ? Theme.border : "transparent"

                        Row {
                            anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                            spacing: 14

                            Text {
                                text: root.selectedIndex === index ? ">" : " "
                                color: Theme.blue
                                font.family: "JetBrains Mono"
                                font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                            }

                            Text {
                                text: modelData.label
                                color: root.selectedIndex === index ? Theme.text : Theme.subtext
                                font.family: "JetBrains Mono"
                                font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Row {
                            anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                            spacing: 4

                            Repeater {
                                model: modelData.swatches
                                delegate: Rectangle {
                                    required property var modelData
                                    width: 10; height: 10; radius: 5
                                    color: modelData
                                }
                            }
                        }

                        Text {
                            anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                            visible: Theme.name === modelData.id
                            text: "*"
                            color: Theme.green
                            font.family: "JetBrains Mono"
                            font.pixelSize: 13
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onEntered: root.selectedIndex = index
                            onClicked: keyNav.activateItem()
                        }
                    }
                }
            }
        }

        // ── Fuzzy search overlay ───────────────────────────────
        Item {
            anchors.fill: parent
            opacity: keyNav.searchOpacity
            visible: keyNav.searchOpacity > 0
            enabled: root.searchQuery !== ""

            Rectangle { anchors.fill: parent; color: Theme.base }

            // Search bar
            Rectangle {
                id: searchBar
                width: parent.width
                height: 44
                color: Theme.surface

                Row {
                    anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                    spacing: 8

                    Text {
                        text: "/"
                        color: Theme.purple
                        font.family: "JetBrains Mono"
                        font.pixelSize: 14
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        text: root.searchQuery
                        color: Theme.text
                        font.family: "JetBrains Mono"
                        font.pixelSize: 13
                        verticalAlignment: Text.AlignVCenter
                    }

                    // Blinking cursor
                    Rectangle {
                        width: 2
                        height: 14
                        color: Theme.blue
                        anchors.verticalCenter: parent.verticalCenter

                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            running: root.searchQuery !== ""
                            NumberAnimation { to: 0; duration: 500; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 1; duration: 500; easing.type: Easing.InOutSine }
                        }
                    }
                }

                Text {
                    anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                    text: root.searchResults.length === 0 ? "no results"
                        : root.searchResults.length + " result" + (root.searchResults.length === 1 ? "" : "s")
                    color: Theme.subtext
                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                }
            }

            Rectangle { id: searchDivider; anchors.top: searchBar.bottom; width: parent.width; height: 1; color: Theme.border }

            ListView {
                id: searchList
                anchors { left: parent.left; right: parent.right; top: searchDivider.bottom; bottom: parent.bottom }
                model: root.searchResults
                clip: true

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    width: searchList.width
                    height: modelData.type === "wallpaper" ? 56 : 44
                    color: root.selectedSearchIndex === index ? Theme.border : "transparent"

                    Row {
                        anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                        spacing: 14

                        Text {
                            text: root.selectedSearchIndex === index ? ">" : " "
                            color: Theme.blue
                            font.family: "JetBrains Mono"
                            font.pixelSize: 13
                            verticalAlignment: Text.AlignVCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 3

                            Text {
                                text: modelData.label
                                color: root.selectedSearchIndex === index ? Theme.text : Theme.subtext
                                font.family: "JetBrains Mono"
                                font.pixelSize: 13
                            }

                            Text {
                                text: modelData.type
                                color: modelData.type === "wallpaper" ? Theme.teal : Theme.yellow
                                font.family: "JetBrains Mono"
                                font.pixelSize: 10
                            }
                        }
                    }

                    // Wallpaper thumbnail
                    Rectangle {
                        anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                        width: 80
                        height: 45
                        radius: 4
                        color: Theme.surface
                        clip: true
                        visible: modelData.type === "wallpaper"

                        Image {
                            anchors.fill: parent
                            source: modelData.type === "wallpaper" ? "file://" + root.wallpapersDir + modelData.file : ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            smooth: true
                        }
                    }

                    // Palette swatches
                    Row {
                        anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                        spacing: 4
                        visible: modelData.type === "palette"

                        Repeater {
                            model: modelData.type === "palette" ? modelData.swatches : []
                            delegate: Rectangle {
                                required property var modelData
                                width: 10; height: 10; radius: 5
                                color: modelData
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onEntered: root.selectedSearchIndex = index
                        onClicked: keyNav.activateSearchItem()
                    }
                }
            }
        }
    }
}

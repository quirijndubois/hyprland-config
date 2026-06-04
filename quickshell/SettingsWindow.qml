import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

FloatingWindow {
    id: root
    implicitWidth: 520
    implicitHeight: 420
    color: Theme.base
    title: "Quickshell Settings"

    signal closeRequested()

    HyprlandFocusGrab {
        windows: [root]
        active: root.visible
        onCleared: root.closeRequested()
    }

    property string page: "main"
    property string activeSubPage: "wallpaper"
    property int selectedIndex: 0
    property string searchQuery: ""
    property int selectedSearchIndex: 0
    property var wallpaperFiles: []
    property var appsList: []
    property var bluetoothDevices: []
    property string currentLayout: "dwindle"
    property string monitorName: ""
    readonly property string wallpapersDir: "/home/q/dev/hyprland-config/wallpapers/"

    onPageChanged: {
        if (page !== "main") activeSubPage = page
        if (page === "bluetooth") btListProc.running = true
        if (page === "layout") layoutQueryProc.running = true
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

    function cleanExec(exec) {
        return exec.replace(/\s*%[a-zA-Z]/g, "").replace(/\s+/g, " ").trim()
    }

    function resolveIcon(icon) {
        if (!icon) return ""
        if (icon.startsWith("/")) return "file://" + icon
        return Quickshell.iconPath(icon, true)
    }

    property var searchResults: {
        if (!searchQuery) return []
        const top = []
        const rest = []
        for (const m of mainItems) {
            if (root.fuzzyMatch(searchQuery, m.label) || root.fuzzyMatch(searchQuery, m.id))
                top.push({ type: "menu", label: m.label, id: m.id })
        }
        for (const f of wallpaperFiles) {
            const name = f.replace(/\.[^.]+$/, "")
            if (root.fuzzyMatch(searchQuery, name))
                rest.push({ type: "wallpaper", label: name, file: f })
        }
        for (const p of paletteOptions) {
            if (root.fuzzyMatch(searchQuery, p.label) || root.fuzzyMatch(searchQuery, p.id))
                rest.push({ type: "palette", label: p.label, id: p.id, swatches: p.swatches })
        }
        for (const a of appsList) {
            if (root.fuzzyMatch(searchQuery, a.name))
                rest.push({ type: "app", label: a.name, exec: a.exec, icon: a.icon })
        }
        for (const d of bluetoothDevices) {
            if (root.fuzzyMatch(searchQuery, d.name))
                rest.push({ type: "bluetooth", label: d.name, mac: d.mac, connected: d.connected, paired: d.paired })
        }
        for (const d of designOptions) {
            if (root.fuzzyMatch(searchQuery, d.label) || root.fuzzyMatch(searchQuery, d.desc))
                rest.push({ type: "design", label: d.label, id: d.id, desc: d.desc, bars: d.bars, barH: d.barH })
        }
        for (const l of layoutOptions) {
            if (root.fuzzyMatch(searchQuery, l.label) || root.fuzzyMatch(searchQuery, l.desc))
                rest.push({ type: "layout", label: l.label, id: l.id, desc: l.desc })
        }
        return top.concat(rest)
    }

    readonly property var paletteOptions: [
        { id: "mocha",       label: "catppuccin mocha",      swatches: ["#89b4fa","#a6e3a1","#f38ba8","#f9e2af","#94e2d5","#cba6f7"] },
        { id: "macchiato",   label: "catppuccin macchiato",  swatches: ["#8aadf4","#a6da95","#ed8796","#eed49f","#8bd5ca","#c6a0f6"] },
        { id: "frappe",      label: "catppuccin frappe",     swatches: ["#8caaee","#a6d189","#e78284","#e5c890","#81c8be","#ca9ee6"] },
        { id: "latte",       label: "catppuccin latte",      swatches: ["#1e66f5","#40a02b","#d20f39","#df8e1d","#179299","#8839ef"] },
        { id: "tokyo-night", label: "tokyo night",           swatches: ["#7aa2f7","#9ece6a","#f7768e","#e0af68","#73daca","#bb9af7"] },
        { id: "gruvbox",     label: "gruvbox",               swatches: ["#83a598","#b8bb26","#fb4934","#fabd2f","#8ec07c","#d3869b"] },
        { id: "nord",        label: "nord",                  swatches: ["#81a1c1","#a3be8c","#bf616a","#ebcb8b","#88c0d0","#b48ead"] },
        { id: "dracula",     label: "dracula",               swatches: ["#6272a4","#50fa7b","#ff5555","#f1fa8c","#8be9fd","#bd93f9"] },
        { id: "rosepine",    label: "rose pine",             swatches: ["#9ccfd8","#31748f","#eb6f92","#f6c177","#ebbcba","#c4a7e7"] },
        { id: "onedark",     label: "one dark",              swatches: ["#61afef","#98c379","#e06c75","#e5c07b","#56b6c2","#c678dd"] },
        { id: "everforest",  label: "everforest",            swatches: ["#7fbbb3","#a7c080","#e67e80","#dbbc7f","#83c092","#d699b6"] },
        { id: "solarized",   label: "solarized dark",        swatches: ["#268bd2","#859900","#dc322f","#b58900","#2aa198","#6c71c4"] },
    ]

    readonly property var designOptions: [
        { id: "default",  label: "default",  desc: "JetBrains Mono · flat",          bars: 1, barH: 6  },
        { id: "compact",  label: "compact",  desc: "JetBrains Mono · slim",          bars: 1, barH: 3  },
        { id: "islands",  label: "islands",  desc: "JetBrains Mono · floating",      bars: 3, barH: 14 },
        { id: "bold",     label: "bold",     desc: "JetBrains Mono bold · tall",     bars: 1, barH: 10 },
        { id: "minimal",  label: "minimal",  desc: "JetBrains Mono · ultra-thin",    bars: 1, barH: 2  },
        { id: "clean",    label: "clean",    desc: "Noto Sans · sans-serif",         bars: 1, barH: 6  },
        { id: "hacker",   label: "hacker",   desc: "Hack · terminal",                bars: 1, barH: 5  },
    ]

    readonly property var layoutOptions: [
        { id: "dwindle",   label: "dwindle",   desc: "BSP spiral tiling" },
        { id: "master",    label: "master",    desc: "master-stack tiling" },
        { id: "scrolling", label: "scrolling", desc: "infinite horizontal tape" },
        { id: "monocle",   label: "monocle",   desc: "fullscreen stack" },
    ]

    readonly property var mainItems: [
        { id: "wallpaper",     label: "wallpaper" },
        { id: "palette",       label: "palette" },
        { id: "design",        label: "design" },
        { id: "layout",        label: "layout" },
        { id: "apps",          label: "applications" },
        { id: "bluetooth",     label: "bluetooth" },
    ]

    onVisibleChanged: {
        if (visible) {
            monitorName = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""
            page = "main"
            selectedIndex = 0
            searchQuery = ""
            Qt.callLater(() => keyNav.forceActiveFocus())
        }
    }

    // ── Discovery processes ────────────────────────────────────
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
        id: appsProc
        command: ["python3", "/home/q/.config/quickshell/list_apps.py"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n").filter(l => l.length > 0)
                root.appsList = lines.map(line => {
                    const parts = line.split("\t")
                    return { name: parts[0] || "", exec: parts[1] || "", icon: parts[2] || "" }
                }).filter(a => a.name && a.exec)
            }
        }
    }

    Process {
        id: awwwProc
        stdout: StdioCollector {}
        stderr: StdioCollector {}
    }

    Process {
        id: btListProc
        command: ["sh", "-c",
            "conn=$(bluetoothctl devices Connected 2>/dev/null | awk '{print $2}'); " +
            "pair=$(bluetoothctl devices Paired 2>/dev/null | awk '{print $2}'); " +
            "bluetoothctl devices 2>/dev/null | while IFS= read -r line; do " +
            "  mac=$(printf '%s' \"$line\" | awk '{print $2}'); " +
            "  name=$(printf '%s' \"$line\" | cut -d' ' -f3-); " +
            "  [ -z \"$mac\" ] && continue; " +
            "  c=no; printf '%s\\n' \"$conn\" | grep -qF \"$mac\" && c=yes; " +
            "  p=no; printf '%s\\n' \"$pair\" | grep -qF \"$mac\" && p=yes; " +
            "  printf '%s\\t%s\\t%s\\t%s\\n' \"$mac\" \"$name\" \"$c\" \"$p\"; " +
            "done"
        ]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n").filter(l => l.length > 0)
                root.bluetoothDevices = lines.map(line => {
                    const parts = line.split("\t")
                    return { mac: parts[0] || "", name: parts[1] || "", connected: parts[2] === "yes", paired: parts[3] === "yes" }
                }).filter(d => d.mac && d.name)
            }
        }
    }

    Process {
        id: btActionProc
        stdout: StdioCollector {}
        stderr: StdioCollector {}
        onRunningChanged: {
            if (!running) btListProc.running = true
        }
    }

    function toggleBluetooth(device) {
        if (btActionProc.running) return
        btActionProc.command = ["bluetoothctl", device.connected ? "disconnect" : "connect", device.mac]
        btActionProc.running = true
    }

    Process {
        id: layoutProc
        stdout: StdioCollector {}
        stderr: StdioCollector {}
    }

    Process {
        id: layoutQueryProc
        command: ["sh", "-c", "hyprctl -j getoption general:layout 2>/dev/null"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const obj = JSON.parse(this.text.trim())
                    if (obj.str) root.currentLayout = obj.str
                } catch(e) {}
            }
        }
    }

    function applyLayout(id) {
        root.currentLayout = id
        layoutProc.command = ["sh", "-c",
            "sed -i 's/^\\(\\s*\\)layout = \"[^\"]*\"/\\1layout = \"" + id + "\"/' " +
            "$HOME/.config/hypr/hyprland.lua && hyprctl reload"
        ]
        layoutProc.running = false
        layoutProc.running = true
    }

    Timer {
        id: btRefreshTimer
        interval: 3000
        repeat: true
        running: root.page === "bluetooth"
        onTriggered: if (!btListProc.running) btListProc.running = true
    }

    property string pendingWallpaper: ""

    function applyWallpaper(filename) {
        if (awwwProc.running) {
            pendingWallpaper = filename
        } else {
            pendingWallpaper = ""
            const types = ["fade", "left", "right", "top", "bottom", "wipe", "wave", "grow", "center", "any", "outer"]
            const type = types[Math.floor(Math.random() * types.length)]
            const cmd = ["awww", "img",
                "--transition-type", type,
                "--transition-duration", "1.5",
                "--transition-fps", "60"]
            if (root.monitorName) cmd.push("--outputs", root.monitorName)
            cmd.push(root.wallpapersDir + filename)
            awwwProc.command = cmd
            awwwProc.running = true
        }
    }

    function launchApp(exec) {
        Quickshell.execDetached(["sh", "-c", root.cleanExec(exec)])
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

        property real offset: root.page !== "main" ? 1.0 : 0.0
        Behavior on offset {
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }

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
                    else if (root.page === "apps")
                        appListView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                    else if (root.page === "bluetooth")
                        btListView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                    else if (root.page === "design")
                        designList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                    else if (root.page === "layout")
                        layoutList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
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
                    const maxIdx = root.page === "main"       ? root.mainItems.length - 1
                                 : root.page === "wallpaper"   ? Math.max(0, root.wallpaperFiles.length - 1)
                                 : root.page === "apps"         ? Math.max(0, root.appsList.length - 1)
                                 : root.page === "bluetooth"    ? Math.max(0, root.bluetoothDevices.length - 1)
                                 : root.page === "design"       ? root.designOptions.length - 1
                                 : root.page === "layout"       ? root.layoutOptions.length - 1
                                 : root.paletteOptions.length - 1
                    if (root.selectedIndex < maxIdx) {
                        root.selectedIndex++
                        if (root.page === "wallpaper")
                            wpList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                        else if (root.page === "palette")
                            paletteList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                        else if (root.page === "apps")
                            appListView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                        else if (root.page === "bluetooth")
                            btListView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                        else if (root.page === "design")
                            designList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                        else if (root.page === "layout")
                            layoutList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                    }
                }
                event.accepted = true
                return
            }

            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (inSearch) activateSearchItem()
                else activateItem()
                event.accepted = true
                return
            }

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
            } else if (root.page === "apps") {
                const app = root.appsList[root.selectedIndex]
                if (app) { root.launchApp(app.exec); root.closeRequested() }
            } else if (root.page === "bluetooth") {
                const dev = root.bluetoothDevices[root.selectedIndex]
                if (dev) root.toggleBluetooth(dev)
            } else if (root.page === "design") {
                const d = root.designOptions[root.selectedIndex]
                if (d) Theme.design = d.id
            } else if (root.page === "layout") {
                const l = root.layoutOptions[root.selectedIndex]
                if (l) root.applyLayout(l.id)
            }
        }

        function activateSearchItem() {
            const result = root.searchResults[root.selectedSearchIndex]
            if (!result) return
            if (result.type === "wallpaper") root.applyWallpaper(result.file)
            else if (result.type === "palette") Theme.name = result.id
            else if (result.type === "app") { root.launchApp(result.exec); root.closeRequested() }
            else if (result.type === "bluetooth") { root.toggleBluetooth(result); return }
            else if (result.type === "design") { Theme.design = result.id }
            else if (result.type === "layout") { root.applyLayout(result.id) }
            else if (result.type === "menu") { root.page = result.id; root.selectedIndex = 0 }
            root.searchQuery = ""
        }

        // ── Main page ──────────────────────────────────────────
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

        // ── Sub-page container ─────────────────────────────────
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

            // ── Applications ───────────────────────────────────
            Item {
                anchors.fill: parent
                visible: root.activeSubPage === "apps"

                Rectangle {
                    id: appsHeader
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
                            text: "applications"
                            color: Theme.purple
                            font.family: "JetBrains Mono"
                            font.pixelSize: 14
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Text {
                        anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                        text: root.appsList.length + " apps"
                        color: Theme.subtext
                        font.family: "JetBrains Mono"
                        font.pixelSize: 11
                    }
                }

                Rectangle { id: appsDivider; anchors.top: appsHeader.bottom; width: parent.width; height: 1; color: Theme.border }

                Text {
                    anchors.centerIn: parent
                    visible: root.appsList.length === 0
                    text: "loading..."
                    color: Theme.subtext
                    font.family: "JetBrains Mono"
                    font.pixelSize: 13
                }

                ListView {
                    id: appListView
                    anchors { left: parent.left; right: parent.right; top: appsDivider.bottom; bottom: parent.bottom }
                    model: root.appsList
                    clip: true
                    visible: root.appsList.length > 0

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width: appListView.width
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
                                text: modelData.name
                                color: root.selectedIndex === index ? Theme.text : Theme.subtext
                                font.family: "JetBrains Mono"
                                font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Rectangle {
                            anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                            width: 45
                            height: 45
                            radius: 4
                            color: Theme.surface
                            clip: true

                            Image {
                                anchors.centerIn: parent
                                width: 32
                                height: 32
                                source: root.resolveIcon(modelData.icon)
                                sourceSize: Qt.size(32, 32)
                                fillMode: Image.PreserveAspectFit
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

            // ── Design ────────────────────────────────────────
            Item {
                anchors.fill: parent
                visible: root.activeSubPage === "design"

                Rectangle {
                    id: designHeader
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
                            text: "design"
                            color: Theme.purple
                            font.family: "JetBrains Mono"
                            font.pixelSize: 14
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Rectangle { id: designDivider; anchors.top: designHeader.bottom; width: parent.width; height: 1; color: Theme.border }

                ListView {
                    id: designList
                    anchors { left: parent.left; right: parent.right; top: designDivider.bottom; bottom: parent.bottom }
                    model: root.designOptions
                    clip: true
                    interactive: false

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width: designList.width
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

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 3

                                Text {
                                    text: modelData.label
                                    color: root.selectedIndex === index ? Theme.text : Theme.subtext
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 13
                                }

                                Text {
                                    text: modelData.desc
                                    color: Theme.purple
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 10
                                }
                            }
                        }

                        // Visual preview of the design layout
                        Row {
                            anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                            spacing: 4

                            Repeater {
                                model: modelData.bars
                                Rectangle {
                                    width: modelData.bars === 1 ? 60 : 18
                                    height: modelData.barH
                                    radius: modelData.bars === 3 ? 4 : 2
                                    color: root.selectedIndex === index ? Theme.blue : Theme.subtext
                                    opacity: root.selectedIndex === index ? 0.7 : 0.35
                                }
                            }
                        }

                        Text {
                            anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                            visible: Theme.design === modelData.id
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
                            onClicked: { Theme.design = modelData.id }
                        }
                    }
                }
            }

            // ── Layout ────────────────────────────────────────
            Item {
                anchors.fill: parent
                visible: root.activeSubPage === "layout"

                Rectangle {
                    id: layoutHeader
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
                            text: "layout"
                            color: Theme.purple
                            font.family: "JetBrains Mono"
                            font.pixelSize: 14
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Rectangle { id: layoutDivider; anchors.top: layoutHeader.bottom; width: parent.width; height: 1; color: Theme.border }

                ListView {
                    id: layoutList
                    anchors { left: parent.left; right: parent.right; top: layoutDivider.bottom; bottom: parent.bottom }
                    model: root.layoutOptions
                    clip: true
                    interactive: false

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width: layoutList.width
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

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 3

                                Text {
                                    text: modelData.label
                                    color: root.selectedIndex === index ? Theme.text : Theme.subtext
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 13
                                }

                                Text {
                                    text: modelData.desc
                                    color: Theme.teal
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 10
                                }
                            }
                        }

                        // Layout diagram
                        Rectangle {
                            anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                            width: 45; height: 45; radius: 4; color: Theme.surface

                            // dwindle: left tall + right top wide + right bottom pair
                            Row {
                                visible: modelData.id === "dwindle"
                                anchors.centerIn: parent; spacing: 1
                                Rectangle { width: 16; height: 37; radius: 2; color: Theme.blue; opacity: 0.45 }
                                Column {
                                    spacing: 1
                                    Rectangle { width: 20; height: 18; radius: 2; color: Theme.blue; opacity: 0.45 }
                                    Row {
                                        spacing: 1
                                        Rectangle { width: 9; height: 18; radius: 2; color: Theme.blue; opacity: 0.45 }
                                        Rectangle { width: 9; height: 18; radius: 2; color: Theme.blue; opacity: 0.45 }
                                    }
                                }
                            }

                            // master: tall left + stacked right
                            Row {
                                visible: modelData.id === "master"
                                anchors.centerIn: parent; spacing: 1
                                Rectangle { width: 20; height: 37; radius: 2; color: Theme.blue; opacity: 0.45 }
                                Column {
                                    spacing: 1
                                    Rectangle { width: 16; height: 18; radius: 2; color: Theme.blue; opacity: 0.45 }
                                    Rectangle { width: 16; height: 18; radius: 2; color: Theme.blue; opacity: 0.45 }
                                }
                            }

                            // scrolling: three equal columns
                            Row {
                                visible: modelData.id === "scrolling"
                                anchors.centerIn: parent; spacing: 1
                                Rectangle { width: 11; height: 37; radius: 2; color: Theme.blue; opacity: 0.45 }
                                Rectangle { width: 11; height: 37; radius: 2; color: Theme.blue; opacity: 0.45 }
                                Rectangle { width: 11; height: 37; radius: 2; color: Theme.blue; opacity: 0.45 }
                            }

                            // monocle: single full window
                            Rectangle {
                                visible: modelData.id === "monocle"
                                anchors.centerIn: parent
                                width: 37; height: 37; radius: 2; color: Theme.blue; opacity: 0.45
                            }
                        }

                        Text {
                            anchors { right: parent.right; rightMargin: 64; verticalCenter: parent.verticalCenter }
                            visible: root.currentLayout === modelData.id
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
                            onClicked: root.applyLayout(modelData.id)
                        }
                    }
                }
            }

            // ── Bluetooth ──────────────────────────────────────
            Item {
                anchors.fill: parent
                visible: root.activeSubPage === "bluetooth"

                Rectangle {
                    id: btHeader
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
                            text: "bluetooth"
                            color: Theme.purple
                            font.family: "JetBrains Mono"
                            font.pixelSize: 14
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Text {
                        anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                        text: root.bluetoothDevices.length + " known"
                        color: Theme.subtext
                        font.family: "JetBrains Mono"
                        font.pixelSize: 11
                    }
                }

                Rectangle { id: btDivider; anchors.top: btHeader.bottom; width: parent.width; height: 1; color: Theme.border }

                Text {
                    anchors.centerIn: parent
                    visible: root.bluetoothDevices.length === 0
                    text: "no known devices"
                    color: Theme.subtext
                    font.family: "JetBrains Mono"
                    font.pixelSize: 13
                }

                ListView {
                    id: btListView
                    anchors { left: parent.left; right: parent.right; top: btDivider.bottom; bottom: parent.bottom }
                    model: root.bluetoothDevices
                    clip: true
                    visible: root.bluetoothDevices.length > 0

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width: btListView.width
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
                                text: modelData.name
                                color: root.selectedIndex === index ? Theme.text : Theme.subtext
                                font.family: "JetBrains Mono"
                                font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Rectangle {
                            anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                            width: 45
                            height: 45
                            radius: 4
                            color: Theme.surface

                            Rectangle {
                                anchors.centerIn: parent
                                width: 10
                                height: 10
                                radius: 5
                                color: modelData.connected ? Theme.green
                                     : modelData.paired    ? Theme.blue
                                     : Theme.subtext
                                opacity: modelData.connected ? 1.0 : 0.35
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onEntered: root.selectedIndex = index
                            onClicked: root.toggleBluetooth(modelData)
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
                    height: (modelData.type === "wallpaper" || modelData.type === "app" || modelData.type === "bluetooth" || modelData.type === "layout") ? 56 : 44
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
                                text: (modelData.type === "design" || modelData.type === "layout") ? modelData.desc
                                    : modelData.type === "menu" ? "open menu"
                                    : modelData.type
                                color: modelData.type === "wallpaper"  ? Theme.teal
                                     : modelData.type === "palette"    ? Theme.yellow
                                     : modelData.type === "bluetooth"  ? Theme.blue
                                     : modelData.type === "design"     ? Theme.purple
                                     : modelData.type === "layout"     ? Theme.teal
                                     : modelData.type === "menu"       ? Theme.purple
                                     : Theme.blue
                                font.family: "JetBrains Mono"
                                font.pixelSize: 10
                            }
                        }
                    }

                    // Wallpaper thumbnail
                    Rectangle {
                        anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                        width: 80; height: 45; radius: 4
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

                    // App icon
                    Rectangle {
                        anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                        width: 45; height: 45; radius: 4
                        color: Theme.surface
                        clip: true
                        visible: modelData.type === "app"

                        Image {
                            anchors.centerIn: parent
                            width: 32; height: 32
                            source: modelData.type === "app" ? root.resolveIcon(modelData.icon) : ""
                            sourceSize: Qt.size(32, 32)
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            smooth: true
                        }
                    }

                    // Bluetooth status dot
                    Rectangle {
                        anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                        width: 45; height: 45; radius: 4
                        color: Theme.surface
                        visible: modelData.type === "bluetooth"

                        Rectangle {
                            anchors.centerIn: parent
                            width: 10; height: 10; radius: 5
                            color: modelData.type === "bluetooth" && modelData.connected ? Theme.green
                                 : modelData.type === "bluetooth" && modelData.paired    ? Theme.blue
                                 : Theme.subtext
                            opacity: (modelData.type === "bluetooth" && modelData.connected) ? 1.0 : 0.35
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

                    // Layout diagram
                    Rectangle {
                        id: layoutSearchPrev
                        property var res: modelData
                        anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                        visible: layoutSearchPrev.res.type === "layout"
                        width: 45; height: 45; radius: 4; color: Theme.surface

                        Row {
                            visible: layoutSearchPrev.res.type === "layout" && layoutSearchPrev.res.id === "dwindle"
                            anchors.centerIn: parent; spacing: 1
                            Rectangle { width: 16; height: 37; radius: 2; color: Theme.blue; opacity: 0.4 }
                            Column {
                                spacing: 1
                                Rectangle { width: 20; height: 18; radius: 2; color: Theme.blue; opacity: 0.4 }
                                Row {
                                    spacing: 1
                                    Rectangle { width: 9; height: 18; radius: 2; color: Theme.blue; opacity: 0.4 }
                                    Rectangle { width: 9; height: 18; radius: 2; color: Theme.blue; opacity: 0.4 }
                                }
                            }
                        }
                        Row {
                            visible: layoutSearchPrev.res.type === "layout" && layoutSearchPrev.res.id === "master"
                            anchors.centerIn: parent; spacing: 1
                            Rectangle { width: 20; height: 37; radius: 2; color: Theme.blue; opacity: 0.4 }
                            Column {
                                spacing: 1
                                Rectangle { width: 16; height: 18; radius: 2; color: Theme.blue; opacity: 0.4 }
                                Rectangle { width: 16; height: 18; radius: 2; color: Theme.blue; opacity: 0.4 }
                            }
                        }
                        Row {
                            visible: layoutSearchPrev.res.type === "layout" && layoutSearchPrev.res.id === "scrolling"
                            anchors.centerIn: parent; spacing: 1
                            Rectangle { width: 11; height: 37; radius: 2; color: Theme.blue; opacity: 0.4 }
                            Rectangle { width: 11; height: 37; radius: 2; color: Theme.blue; opacity: 0.4 }
                            Rectangle { width: 11; height: 37; radius: 2; color: Theme.blue; opacity: 0.4 }
                        }
                        Rectangle {
                            visible: layoutSearchPrev.res.type === "layout" && layoutSearchPrev.res.id === "monocle"
                            anchors.centerIn: parent
                            width: 37; height: 37; radius: 2; color: Theme.blue; opacity: 0.4
                        }
                    }

                    // Menu arrow
                    Text {
                        anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                        visible: modelData.type === "menu"
                        text: ">"
                        color: Theme.subtext
                        font.family: "JetBrains Mono"
                        font.pixelSize: 12
                    }

                    // Design bar preview
                    Item {
                        id: designPrev
                        property var res: modelData
                        anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                        visible: designPrev.res.type === "design"
                        width: 60; height: 30

                        // Single-bar designs
                        Rectangle {
                            anchors.centerIn: parent
                            visible: designPrev.res.type === "design" && designPrev.res.bars === 1
                            width: 50
                            height: Math.max(2, designPrev.res.barH || 0)
                            radius: 2
                            color: Theme.subtext; opacity: 0.45
                        }

                        // Islands design (3 pills)
                        Row {
                            anchors.centerIn: parent
                            spacing: 3
                            visible: designPrev.res.type === "design" && designPrev.res.bars === 3
                            Rectangle { width: 13; height: designPrev.res.barH || 0; radius: 3; color: Theme.subtext; opacity: 0.45 }
                            Rectangle { width: 13; height: designPrev.res.barH || 0; radius: 3; color: Theme.subtext; opacity: 0.45 }
                            Rectangle { width: 13; height: designPrev.res.barH || 0; radius: 3; color: Theme.subtext; opacity: 0.45 }
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

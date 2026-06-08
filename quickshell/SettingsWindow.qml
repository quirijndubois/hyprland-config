import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Notifications
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
    property string requestedPage: "main"
    property int selectedIndex: 0
    property string searchQuery: ""
    property int selectedSearchIndex: 0
    property var wallpaperFiles: []
    property string homeDir: ""
    property bool isPathMode: searchQuery.length > 0 && (searchQuery[0] === "/" || searchQuery.startsWith("~/"))
    property string pathExpanded: (searchQuery.startsWith("~/") && homeDir) ? homeDir + searchQuery.substring(1) : searchQuery
    property string pathDir: {
        if (!isPathMode) return ""
        const i = pathExpanded.lastIndexOf("/")
        return pathExpanded.substring(0, i + 1)
    }
    property string pathFilter: {
        if (!isPathMode) return ""
        const i = pathExpanded.lastIndexOf("/")
        return pathExpanded.substring(i + 1).toLowerCase()
    }
    property var fileEntries: []
    onPathDirChanged: {
        root.fileEntries = []
        if (root.pathDir) {
            lsProc.command = ["ls", "-1p", "--color=never", "--", root.pathDir]
            lsProc.running = false
            lsProc.running = true
        }
    }
    property var appsList: []
    property var bluetoothDevices: []
    property string currentLayout: "dwindle"
    property string monitorName: ""
    readonly property string wallpapersDir: "/home/q/dev/hyprland-config/wallpapers/"
    property var systemMonitors: []
    property real mouseSensitivity: 0.0
    property bool naturalScroll: true
    property real scrollFactor: 0.4

    property var systemSettingItems: {
        const items = []
        items.push({ type: "section", label: "display" })
        for (const m of root.systemMonitors)
            items.push({ type: "scale", label: m.name, sub: m.width + "×" + m.height, monitor: m })
        items.push({ type: "section", label: "input" })
        items.push({ type: "sensitivity",    label: "mouse sensitivity" })
        items.push({ type: "natural_scroll", label: "natural scroll" })
        items.push({ type: "scroll_factor",  label: "scroll factor" })
        return items
    }

    onPageChanged: {
        if (page !== "main") activeSubPage = page
        if (page === "bluetooth") btListProc.running = true
        if (page === "layout") layoutQueryProc.running = true
        if (page === "clipboard") clipListProc.running = true
        if (page === "system") {
            sysMonitorsProc.running = false
            sysMonitorsProc.running = true
            sysSensProc.running = false
            sysSensProc.running = true
        }
    }

    onSearchQueryChanged: {
        selectedSearchIndex = 0
    }

    function fuzzyScore(query, str) {
        query = query.toLowerCase()
        str = str.toLowerCase()
        if (str === query) return 100
        if (str.startsWith(query)) return 50
        let qi = 0
        for (let i = 0; i < str.length && qi < query.length; i++) {
            if (str[i] === query[qi]) qi++
        }
        return qi === query.length ? 10 : 0
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
        if (isPathMode) {
            const entries = fileEntries
            const f = pathFilter
            if (!f) return entries.map(e => ({ type: "file", label: e.name + (e.isDir ? "/" : ""), name: e.name, isDir: e.isDir, path: e.path }))
            return entries
                .filter(e => e.name.toLowerCase().includes(f))
                .map(e => ({ type: "file", label: e.name + (e.isDir ? "/" : ""), name: e.name, isDir: e.isDir, path: e.path,
                              score: e.name.toLowerCase().startsWith(f) ? 50 : 10 }))
                .sort((a, b) => (b.score || 0) - (a.score || 0))
        }
        const results = []
        for (const m of mainItems) {
            const s = Math.max(root.fuzzyScore(searchQuery, m.label), root.fuzzyScore(searchQuery, m.id))
            if (s > 0) results.push({ score: s, type: "menu", label: m.label, id: m.id })
        }
        for (const f of wallpaperFiles) {
            const name = f.replace(/\.[^.]+$/, "")
            const s = root.fuzzyScore(searchQuery, name)
            if (s > 0) results.push({ score: s, type: "wallpaper", label: name, file: f })
        }
        for (const p of paletteOptions) {
            const s = Math.max(root.fuzzyScore(searchQuery, p.label), root.fuzzyScore(searchQuery, p.id))
            if (s > 0) results.push({ score: s, type: "palette", label: p.label, id: p.id, swatches: p.swatches })
        }
        for (const a of appsList) {
            const s = root.fuzzyScore(searchQuery, a.name)
            if (s > 0) results.push({ score: s, type: "app", label: a.name, exec: a.exec, icon: a.icon, terminal: a.terminal })
        }
        for (const d of bluetoothDevices) {
            const s = root.fuzzyScore(searchQuery, d.name)
            if (s > 0) results.push({ score: s, type: "bluetooth", label: d.name, mac: d.mac, connected: d.connected, paired: d.paired })
        }
        for (const d of designOptions) {
            const s = Math.max(root.fuzzyScore(searchQuery, d.label), root.fuzzyScore(searchQuery, d.desc))
            if (s > 0) results.push({ score: s, type: "design", label: d.label, id: d.id, desc: d.desc, bars: d.bars, barH: d.barH })
        }
        for (const l of layoutOptions) {
            const s = Math.max(root.fuzzyScore(searchQuery, l.label), root.fuzzyScore(searchQuery, l.desc))
            if (s > 0) results.push({ score: s, type: "layout", label: l.label, id: l.id, desc: l.desc })
        }
        for (const c of clipboardItems) {
            const s = root.fuzzyScore(searchQuery, c.preview)
            if (s > 0) results.push({ score: s, type: "clipboard", label: c.preview, line: c.line })
        }
        results.sort((a, b) => b.score - a.score)
        if (results.length === 0 && !mathResult) results.push({ type: "web", label: searchQuery })
        if (mathResult) results.unshift({ type: "math", label: mathResult.result, expr: mathResult.expr })
        return results
    }

    property var mathResult: {
        const q = searchQuery.trim()
        if (!q || isPathMode) return null
        if (!/^[\d\s\+\-\*\/\%\.\(\)\^]+$/.test(q)) return null
        if (!/[\+\-\*\/\%\^]/.test(q)) return null
        try {
            const val = eval(q.replace(/\^/g, "**"))
            if (typeof val !== "number" || !isFinite(val)) return null
            const formatted = Number.isInteger(val) ? String(val) : parseFloat(val.toPrecision(10)).toString()
            return { expr: q, result: formatted }
        } catch(e) { return null }
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
        { id: "pills",    label: "pills",    desc: "JetBrains Mono · per-module pills", bars: 5, barH: 14 },
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

    readonly property var barModules: [
        { id: "showMenu",      label: "menu button" },
        { id: "showClock",     label: "clock" },
        { id: "showBattery",   label: "battery" },
        { id: "showCpu",       label: "cpu" },
        { id: "showMemory",    label: "memory" },
        { id: "showGpu",       label: "gpu" },
        { id: "showWorkspaces", label: "workspaces" },
        { id: "showMusic",     label: "music visualizer" },
        { id: "showAudio",     label: "audio" },
        { id: "showBluetooth", label: "bluetooth" },
        { id: "showNetwork",   label: "network" },
        { id: "inhibit",       label: "inhibit sleep" },
        { id: "showTray",      label: "tray" },
    ]

    property var mainItems: [
        { id: "wallpaper",     label: "wallpaper",     icon: "" },
        { id: "palette",       label: "palette",       icon: "" },
        { id: "design",        label: "design",        icon: "" },
        { id: "layout",        label: "layout",        icon: "" },
        { id: "apps",          label: "applications",  icon: "" },
        { id: "bluetooth",     label: "bluetooth",     icon: "" },
        { id: "clipboard",     label: "clipboard",     icon: "" },
        { id: "bar",           label: "bar",           icon: "" },
        { id: "notifications", label: "notifications", icon: "" },
        { id: "system",        label: "system",        icon: "" },
    ]

    onVisibleChanged: {
        if (visible) {
            monitorName = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""
            page = requestedPage
            requestedPage = "main"
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
                        return { name: parts[0] || "", exec: parts[1] || "", icon: parts[2] || "", terminal: parts[3] === "true" }
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

    Process { id: saveItemsProc }
    Process { id: clipProc; stdout: StdioCollector {} }

    Process {
        id: sysMonitorsProc
        command: ["sh", "-c", "hyprctl -j monitors 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.systemMonitors = JSON.parse(this.text.trim()).map(m => ({
                        name: m.name,
                        desc: (m.description || m.name).split(" ")[0],
                        width: m.width, height: m.height,
                        refreshRate: m.refreshRate || 60,
                        x: m.x, y: m.y,
                        scale: m.scale || 1.0
                    }))
                } catch(e) {}
            }
        }
    }

    Process {
        id: sysSensProc
        command: ["sh", "-c",
            "hyprctl -j getoption input:sensitivity 2>/dev/null; " +
            "hyprctl -j getoption input:touchpad:natural_scroll 2>/dev/null; " +
            "hyprctl -j getoption input:touchpad:scroll_factor 2>/dev/null"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                const text = this.text.trim()
                let depth = 0, start = 0
                const objects = []
                for (let i = 0; i < text.length; i++) {
                    if (text[i] === '{') { if (depth === 0) start = i; depth++ }
                    else if (text[i] === '}') { depth--; if (depth === 0) objects.push(text.slice(start, i + 1)) }
                }
                try { const o = JSON.parse(objects[0]); if (o.float !== undefined) root.mouseSensitivity = Math.round(o.float * 10) / 10 } catch(e) {}
                try { const o = JSON.parse(objects[1]); if (o.int !== undefined) root.naturalScroll = o.int === 1 } catch(e) {}
                try { const o = JSON.parse(objects[2]); if (o.float !== undefined) root.scrollFactor = Math.round(o.float * 20) / 20 } catch(e) {}
            }
        }
    }

    Process {
        id: sysApplyProc
        stdout: StdioCollector {}
        stderr: StdioCollector {}
    }

    function _writeUserSettings() {
        const lines = []
        for (const m of root.systemMonitors)
            lines.push('hl.monitor({ output = "' + m.name + '", mode = "' + m.width + 'x' + m.height + '", position = "' + m.x + 'x' + m.y + '", scale = ' + m.scale + ' })')
        const ns = root.naturalScroll ? 'true' : 'false'
        lines.push('hl.config({ input = { sensitivity = ' + root.mouseSensitivity + ', touchpad = { natural_scroll = ' + ns + ', scroll_factor = ' + root.scrollFactor + ' } } })')
        const args = lines.map(l => "'" + l + "'").join(' ')
        return "printf '%s\\n' " + args + " > \"$HOME/.config/hypr/user-settings.lua\""
    }

    function _rescaleCmd() {
        let cmd = ""
        for (const m of root.systemMonitors)
            cmd += " ; hyprctl eval \"hl.monitor({ output = '" + m.name + "', mode = '" + m.width + "x" + m.height + "', position = '" + m.x + "x" + m.y + "', scale = " + m.scale + " })\""
        return cmd
    }

    function setMonitorScale(mon, scale) {
        const idx = root.systemMonitors.findIndex(m => m.name === mon.name)
        if (idx >= 0) {
            const arr = Array.from(root.systemMonitors)
            arr[idx] = Object.assign({}, arr[idx], { scale: scale })
            root.systemMonitors = arr
        }
        const evalCmd = "hyprctl eval \"hl.monitor({ output = '" + mon.name + "', mode = '" + mon.width + "x" + mon.height + "', position = '" + mon.x + "x" + mon.y + "', scale = " + scale + " })\""
        sysApplyProc.command = ["sh", "-c", root._writeUserSettings() + " ; " + evalCmd]
        sysApplyProc.running = false
        sysApplyProc.running = true
    }

    function setMouseSensitivity(val) {
        val = Math.round(Math.max(-1.0, Math.min(1.0, val)) * 10) / 10
        root.mouseSensitivity = val
        sysApplyProc.command = ["sh", "-c",
            root._writeUserSettings() +
            " ; hyprctl keyword input:sensitivity " + val +
            root._rescaleCmd()
        ]
        sysApplyProc.running = false
        sysApplyProc.running = true
    }

    function setNaturalScroll(val) {
        root.naturalScroll = val
        sysApplyProc.command = ["sh", "-c",
            root._writeUserSettings() +
            " ; hyprctl keyword input:touchpad:natural_scroll " + (val ? 1 : 0) +
            root._rescaleCmd()
        ]
        sysApplyProc.running = false
        sysApplyProc.running = true
    }

    function setScrollFactor(val) {
        val = Math.round(Math.max(0.1, Math.min(3.0, val)) * 20) / 20
        root.scrollFactor = val
        sysApplyProc.command = ["sh", "-c",
            root._writeUserSettings() +
            " ; hyprctl keyword input:touchpad:scroll_factor " + val +
            root._rescaleCmd()
        ]
        sysApplyProc.running = false
        sysApplyProc.running = true
    }

    property var clipboardItems: []

    Process {
        id: clipListProc
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n").filter(l => l.length > 0)
                root.clipboardItems = lines.map(l => {
                    const tab = l.indexOf("\t")
                    return tab === -1
                        ? { id: l, preview: l, line: l }
                        : { id: l.substring(0, tab), preview: l.substring(tab + 1), line: l }
                })
            }
        }
    }

    Process {
        id: clipDecodeProc
        stdout: StdioCollector {}
        stderr: StdioCollector {}
    }

    Timer {
        interval: 3000
        repeat: true
        running: root.page === "clipboard"
        onTriggered: if (!clipListProc.running) clipListProc.running = true
    }

    function copyClipboardItem(line) {
        clipDecodeProc.command = ["sh", "-c", "printf '%s\\n' \"$1\" | cliphist decode | wl-copy", "--", line]
        clipDecodeProc.running = false
        clipDecodeProc.running = true
    }

    Process {
        id: homeDirProc
        command: ["sh", "-c", "printf '%s' \"$HOME\""]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.homeDir = this.text.trim()
        }
    }

    Process {
        id: lsProc
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.split("\n").filter(l => l.length > 0)
                root.fileEntries = lines.map(l => {
                    const isDir = l.endsWith("/")
                    const name = isDir ? l.slice(0, -1) : l
                    return { name: name, isDir: isDir, path: root.pathDir + name }
                })
            }
        }
    }

    Process {
        id: loadItemsProc
        command: ["sh", "-c", "cat $HOME/.config/quickshell/main-items 2>/dev/null"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const ids = this.text.trim().split(/\s+/).filter(id => id.length > 0)
                if (ids.length > 0) {
                    const order = {}
                    ids.forEach((id, i) => { order[id] = i })
                    const items = Array.from(root.mainItems)
                    items.sort((a, b) => (order[a.id] ?? 999) - (order[b.id] ?? 999))
                    root.mainItems = items
                }
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

    function launchApp(exec, terminal) {
        const cmd = root.cleanExec(exec)
        if (terminal) {
            Quickshell.execDetached(["sh", "-c", "kitty -e " + cmd])
        } else {
            Quickshell.execDetached(["sh", "-c", cmd])
        }
    }

    function saveMainItems() {
        const ids = root.mainItems.map(m => m.id).join(" ")
        saveItemsProc.command = ["sh", "-c", "mkdir -p \"$HOME/.config/quickshell\" && printf '%s' '" + ids + "' > $HOME/.config/quickshell/main-items"]
        saveItemsProc.running = false
        saveItemsProc.running = true
    }

    function toggleBarModule(id) {
        if (id === "inhibit") InhibitState.inhibited = !InhibitState.inhibited
        else Theme[id] = !Theme[id]
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

        property real lastCursorX: -9999
        property real lastCursorY: -9999

        function hoverMoved(item, mx, my) {
            const g = item.mapToItem(keyNav, mx, my)
            if (g.x === lastCursorX && g.y === lastCursorY) return false
            lastCursorX = g.x; lastCursorY = g.y
            return true
        }

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
                const shiftHeld = (event.modifiers & Qt.ShiftModifier) !== 0
                if (inSearch) {
                    if (root.selectedSearchIndex > 0) {
                        root.selectedSearchIndex--
                        searchList.positionViewAtIndex(root.selectedSearchIndex, ListView.Contain)
                    }
                } else if (shiftHeld && root.page === "main" && root.selectedIndex > 0) {
                    const items = Array.from(root.mainItems)
                    const i = root.selectedIndex
                    const tmp = items[i]; items[i] = items[i - 1]; items[i - 1] = tmp
                    root.mainItems = items
                    root.selectedIndex = i - 1
                    root.saveMainItems()
                    mainList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                } else if (root.selectedIndex > 0) {
                    root.selectedIndex--
                    if (root.page === "main")
                        mainList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                    else if (root.page === "wallpaper")
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
                    else if (root.page === "bar")
                        barListView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                    else if (root.page === "clipboard")
                        clipListView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                    else if (root.page === "notifications")
                        notifListView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                    else if (root.page === "system")
                        sysListView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                }
                event.accepted = true
                return
            }

            if (event.key === Qt.Key_Down) {
                const shiftHeld = (event.modifiers & Qt.ShiftModifier) !== 0
                const maxIdx = root.page === "main"          ? root.mainItems.length - 1
                             : root.page === "wallpaper"      ? Math.max(0, root.wallpaperFiles.length - 1)
                             : root.page === "apps"           ? Math.max(0, root.appsList.length - 1)
                             : root.page === "bluetooth"      ? Math.max(0, root.bluetoothDevices.length - 1)
                             : root.page === "design"         ? root.designOptions.length - 1
                             : root.page === "layout"         ? root.layoutOptions.length - 1
                             : root.page === "bar"            ? Math.max(0, root.barModules.length - 1)
                             : root.page === "clipboard"      ? Math.max(0, root.clipboardItems.length - 1)
                             : root.page === "notifications"  ? Math.max(0, notifListView.count - 1)
                             : root.page === "system"         ? Math.max(0, root.systemSettingItems.length - 1)
                             : root.paletteOptions.length - 1
                if (inSearch) {
                    if (root.selectedSearchIndex < root.searchResults.length - 1) {
                        root.selectedSearchIndex++
                        searchList.positionViewAtIndex(root.selectedSearchIndex, ListView.Contain)
                    }
                } else if (shiftHeld && root.page === "main" && root.selectedIndex < maxIdx) {
                    const items = Array.from(root.mainItems)
                    const i = root.selectedIndex
                    const tmp = items[i]; items[i] = items[i + 1]; items[i + 1] = tmp
                    root.mainItems = items
                    root.selectedIndex = i + 1
                    root.saveMainItems()
                    mainList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                } else if (root.selectedIndex < maxIdx) {
                    root.selectedIndex++
                    if (root.page === "main")
                        mainList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                    else if (root.page === "wallpaper")
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
                    else if (root.page === "bar")
                        barListView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                    else if (root.page === "clipboard")
                        clipListView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                    else if (root.page === "notifications")
                        notifListView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                    else if (root.page === "system")
                        sysListView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                }
                event.accepted = true
                return
            }

            if (event.key === Qt.Key_Left || event.key === Qt.Key_Right) {
                if (!inSearch && root.page === "system") {
                    const item = root.systemSettingItems[root.selectedIndex]
                    if (item && item.type !== "section") {
                        const dir = event.key === Qt.Key_Right ? 1 : -1
                        if (item.type === "sensitivity") {
                            root.setMouseSensitivity(root.mouseSensitivity + dir * 0.1)
                        } else if (item.type === "scroll_factor") {
                            root.setScrollFactor(root.scrollFactor + dir * 0.05)
                        } else if (item.type === "scale") {
                            const scales = [1, 1.25, 1.5, 2]
                            const ci = scales.findIndex(s => Math.abs(item.monitor.scale - s) < 0.01)
                            const ni = Math.max(0, Math.min(scales.length - 1, (ci < 0 ? 0 : ci) + dir))
                            root.setMonitorScale(item.monitor, scales[ni])
                        }
                    }
                    event.accepted = true
                    return
                }
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
                if (app) { root.launchApp(app.exec, app.terminal); root.closeRequested() }
            } else if (root.page === "bluetooth") {
                const dev = root.bluetoothDevices[root.selectedIndex]
                if (dev) root.toggleBluetooth(dev)
            } else if (root.page === "design") {
                const d = root.designOptions[root.selectedIndex]
                if (d) Theme.design = d.id
            }             else if (root.page === "layout") {
                const l = root.layoutOptions[root.selectedIndex]
                if (l) root.applyLayout(l.id)
            } else if (root.page === "bar") {
                const mod = root.barModules[root.selectedIndex]
                if (mod) root.toggleBarModule(mod.id)
            } else if (root.page === "clipboard") {
                const item = root.clipboardItems[root.selectedIndex]
                if (item) { root.copyClipboardItem(item.line); root.closeRequested() }
            } else if (root.page === "notifications") {
                const ni = notifListView.itemAtIndex(root.selectedIndex)
                if (ni) ni.dismiss()
            } else if (root.page === "system") {
                const item = root.systemSettingItems[root.selectedIndex]
                if (!item || item.type === "section") return
                if (item.type === "scale") {
                    const scales = [1, 1.25, 1.5, 2]
                    const curIdx = scales.findIndex(s => Math.abs(item.monitor.scale - s) < 0.01)
                    root.setMonitorScale(item.monitor, scales[(curIdx + 1) % scales.length])
                } else if (item.type === "sensitivity") {
                    root.setMouseSensitivity(root.mouseSensitivity + 0.1)
                } else if (item.type === "natural_scroll") {
                    root.setNaturalScroll(!root.naturalScroll)
                } else if (item.type === "scroll_factor") {
                    root.setScrollFactor(root.scrollFactor + 0.05)
                }
            }
        }

        function activateSearchItem() {
            const result = root.searchResults[root.selectedSearchIndex]
            if (!result) return
            if (result.type === "web") {
                Quickshell.execDetached(["xdg-open", "https://duckduckgo.com/?q=" + encodeURIComponent(root.searchQuery)])
                root.closeRequested()
                return
            }
            if (result.type === "math") {
                clipProc.command = ["sh", "-c", "printf '%s' '" + result.label + "' | wl-copy"]
                clipProc.running = false
                clipProc.running = true
                root.searchQuery = ""
                return
            }
            if (result.type === "file") {
                if (result.isDir) {
                    root.searchQuery = result.path + "/"
                } else {
                    Quickshell.execDetached(["xdg-open", result.path])
                    root.closeRequested()
                }
                return
            }
            if (result.type === "wallpaper") root.applyWallpaper(result.file)
            else if (result.type === "palette") Theme.name = result.id
            else if (result.type === "app") { root.launchApp(result.exec, result.terminal); root.closeRequested() }
            else if (result.type === "bluetooth") { root.toggleBluetooth(result); return }
            else if (result.type === "design") { Theme.design = result.id }
            else if (result.type === "layout") { root.applyLayout(result.id) }
            else if (result.type === "menu") { root.page = result.id; root.selectedIndex = 0 }
            else if (result.type === "clipboard") { root.copyClipboardItem(result.line); root.closeRequested(); return }
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
                anchors { left: parent.left; right: parent.right; top: mainHeader.bottom; bottom: parent.bottom; topMargin: 1 }
                model: root.mainItems
                clip: true

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    width: mainList.width
                    height: 44
                    color: root.selectedIndex === index ? Theme.border : "transparent"

                    Row {
                        anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                        spacing: 10

                        Text {
                            text: root.selectedIndex === index ? ">" : " "
                            color: Theme.blue
                            font.family: "JetBrains Mono"
                            font.pixelSize: 13
                            verticalAlignment: Text.AlignVCenter
                            width: 12
                        }

                        Text {
                            text: modelData.icon || ""
                            color: Theme.purple
                            font.family: "Symbols Nerd Font Mono"
                            font.pixelSize: 14
                            verticalAlignment: Text.AlignVCenter
                            width: 20
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
                        onPositionChanged: mouse => { if (keyNav.hoverMoved(this, mouse.x, mouse.y)) root.selectedIndex = index }
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
                            onPositionChanged: mouse => { if (keyNav.hoverMoved(this, mouse.x, mouse.y)) root.selectedIndex = index }
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
                            onPositionChanged: mouse => { if (keyNav.hoverMoved(this, mouse.x, mouse.y)) root.selectedIndex = index }
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
                            onPositionChanged: mouse => { if (keyNav.hoverMoved(this, mouse.x, mouse.y)) root.selectedIndex = index }
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
                                    width: modelData.bars === 1 ? 60 : modelData.bars === 5 ? 10 : 18
                                    height: modelData.barH
                                    radius: modelData.bars === 3 ? 4 : modelData.bars === 5 ? modelData.barH / 2 : 2
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
                            onPositionChanged: mouse => { if (keyNav.hoverMoved(this, mouse.x, mouse.y)) root.selectedIndex = index }
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
                            onPositionChanged: mouse => { if (keyNav.hoverMoved(this, mouse.x, mouse.y)) root.selectedIndex = index }
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
                            onPositionChanged: mouse => { if (keyNav.hoverMoved(this, mouse.x, mouse.y)) root.selectedIndex = index }
                            onClicked: root.toggleBluetooth(modelData)
                        }
                    }
                }
            }

            // ── Clipboard ─────────────────────────────────────
            Item {
                anchors.fill: parent
                visible: root.activeSubPage === "clipboard"

                Rectangle {
                    id: clipHeader
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
                            text: "clipboard"
                            color: Theme.purple
                            font.family: "JetBrains Mono"
                            font.pixelSize: 14
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Text {
                        anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                        text: root.clipboardItems.length + " entries"
                        color: Theme.subtext
                        font.family: "JetBrains Mono"
                        font.pixelSize: 11
                    }
                }

                Rectangle { id: clipDivider; anchors.top: clipHeader.bottom; width: parent.width; height: 1; color: Theme.border }

                Text {
                    anchors.centerIn: parent
                    visible: root.clipboardItems.length === 0
                    text: "no history  —  run: wl-paste --watch cliphist store"
                    color: Theme.subtext
                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                }

                ListView {
                    id: clipListView
                    anchors { left: parent.left; right: parent.right; top: clipDivider.bottom; bottom: parent.bottom }
                    model: root.clipboardItems
                    clip: true
                    visible: root.clipboardItems.length > 0

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width: clipListView.width
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
                                text: modelData.preview
                                color: root.selectedIndex === index ? Theme.text : Theme.subtext
                                font.family: "JetBrains Mono"
                                font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                                width: clipListView.width - 80
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onPositionChanged: mouse => { if (keyNav.hoverMoved(this, mouse.x, mouse.y)) root.selectedIndex = index }
                            onClicked: { root.copyClipboardItem(modelData.line); root.closeRequested() }
                        }
                    }
                }
            }

            // ── Bar ───────────────────────────────────────────
            Item {
                anchors.fill: parent
                visible: root.activeSubPage === "bar"

                Rectangle {
                    id: barHeader
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
                            text: "bar modules"
                            color: Theme.purple
                            font.family: "JetBrains Mono"
                            font.pixelSize: 14
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Text {
                        anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                        text: root.barModules.length + " modules"
                        color: Theme.subtext
                        font.family: "JetBrains Mono"
                        font.pixelSize: 11
                    }
                }

                Rectangle { id: barDivider; anchors.top: barHeader.bottom; width: parent.width; height: 1; color: Theme.border }

                ListView {
                    id: barListView
                    anchors { left: parent.left; right: parent.right; top: barDivider.bottom; bottom: parent.bottom }
                    model: root.barModules
                    clip: true
                    interactive: false

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width: barListView.width
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
                            property bool active: modelData.id === "inhibit" ? InhibitState.inhibited : !!Theme[modelData.id]
                            text:  active ? "[*]" : "[ ]"
                            color: modelData.id === "inhibit"
                                ? (active ? Theme.yellow : Theme.subtext)
                                : (active ? Theme.green  : Theme.subtext)
                            font.family: "JetBrains Mono"
                            font.pixelSize: 13
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onPositionChanged: mouse => { if (keyNav.hoverMoved(this, mouse.x, mouse.y)) root.selectedIndex = index }
                            onClicked: root.toggleBarModule(modelData.id)
                        }
                    }
                }
            }
            // ── Notifications ──────────────────────────────────
            Item {
                anchors.fill: parent
                visible: root.activeSubPage === "notifications"

                Rectangle {
                    id: notifHeader
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
                            text: "notifications"
                            color: Theme.purple
                            font.family: "JetBrains Mono"
                            font.pixelSize: 14
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Row {
                        anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                        spacing: 12

                        Text {
                            text: notifListView.count + " total"
                            color: Theme.subtext
                            font.family: "JetBrains Mono"
                            font.pixelSize: 11
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            visible: notifListView.count > 0
                            text: "clear all"
                            color: Theme.red
                            font.family: "JetBrains Mono"
                            font.pixelSize: 11
                            verticalAlignment: Text.AlignVCenter
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Notifications.clearAll()
                            }
                        }
                    }
                }

                Rectangle { id: notifDivider; anchors.top: notifHeader.bottom; width: parent.width; height: 1; color: Theme.border }

                Text {
                    anchors.centerIn: parent
                    visible: notifListView.count === 0
                    text: "no notifications"
                    color: Theme.subtext
                    font.family: "JetBrains Mono"
                    font.pixelSize: 13
                }

                ListView {
                    id: notifListView
                    anchors { left: parent.left; right: parent.right; top: notifDivider.bottom; bottom: parent.bottom }
                    model: Notifications.history
                    clip: true
                    visible: notifListView.count > 0

                    delegate: Rectangle {
                        id: notifDelegate
                        required property var modelData
                        required property int index

                        width: notifListView.width
                        height: 64
                        color: root.selectedIndex === index ? Theme.border : "transparent"

                        function dismiss() {
                            Notifications.dismiss(modelData.id)
                        }

                        // Urgency bar on left edge
                        Rectangle {
                            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                            width: 3
                            color: modelData.urgency === NotificationUrgency.Critical ? Theme.red
                                 : modelData.urgency === NotificationUrgency.Low      ? Theme.subtext
                                 : Theme.blue
                        }

                        Column {
                            anchors {
                                left: parent.left; leftMargin: 16
                                right: dismissBtn.left; rightMargin: 8
                                verticalCenter: parent.verticalCenter
                            }
                            spacing: 3

                            Text {
                                width: parent.width
                                text: modelData.appName || "unknown"
                                color: modelData.urgency === NotificationUrgency.Critical ? Theme.red
                                     : modelData.urgency === NotificationUrgency.Low      ? Theme.subtext
                                     : Theme.blue
                                font.family: "JetBrains Mono"
                                font.pixelSize: 10
                                elide: Text.ElideRight
                            }

                            Text {
                                width: parent.width
                                text: modelData.summary || ""
                                color: root.selectedIndex === index ? Theme.text : Theme.text
                                font.family: "JetBrains Mono"
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                                visible: text !== ""
                            }

                            Text {
                                width: parent.width
                                text: modelData.body || ""
                                color: Theme.subtext
                                font.family: "JetBrains Mono"
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                visible: text !== ""
                            }
                        }

                        Text {
                            id: dismissBtn
                            anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                            text: "x"
                            color: root.selectedIndex === index ? Theme.red : Theme.subtext
                            font.family: "JetBrains Mono"
                            font.pixelSize: 13
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: notifDelegate.dismiss()
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onPositionChanged: mouse => { if (keyNav.hoverMoved(this, mouse.x, mouse.y)) root.selectedIndex = index }
                        }
                    }
                }
            }

            // ── System ────────────────────────────────────────
            Item {
                anchors.fill: parent
                visible: root.activeSubPage === "system"

                Rectangle {
                    id: sysHeader
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
                            text: "system"
                            color: Theme.purple
                            font.family: "JetBrains Mono"
                            font.pixelSize: 14
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Rectangle { id: sysDivider; anchors.top: sysHeader.bottom; width: parent.width; height: 1; color: Theme.border }

                ListView {
                    id: sysListView
                    anchors { left: parent.left; right: parent.right; top: sysDivider.bottom; bottom: parent.bottom }
                    model: root.systemSettingItems
                    clip: true
                    interactive: true

                    delegate: Item {
                        id: sysDelegate
                        required property var modelData
                        required property int index
                        property bool isSection: sysDelegate.modelData.type === "section"
                        property bool isSelected: root.selectedIndex === sysDelegate.index

                        width: sysListView.width
                        height: isSection ? 32 : 48

                        // Section header background
                        Rectangle {
                            anchors.fill: parent
                            visible: sysDelegate.isSection
                            color: Theme.surface

                            Text {
                                anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                                text: sysDelegate.modelData.label || ""
                                color: Theme.blue
                                font.family: "JetBrains Mono"
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }

                        // Interactive row
                        Rectangle {
                            anchors.fill: parent
                            visible: !sysDelegate.isSection
                            color: sysDelegate.isSelected ? Theme.border : "transparent"

                            // Cursor indicator
                            Text {
                                anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                                visible: sysDelegate.isSelected
                                text: ">"
                                color: Theme.blue
                                font.family: "JetBrains Mono"
                                font.pixelSize: 13
                            }

                            // Label column
                            Column {
                                anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                                spacing: 2

                                Text {
                                    text: sysDelegate.modelData.label || ""
                                    color: sysDelegate.isSelected ? Theme.text : Theme.subtext
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 12
                                }

                                Text {
                                    visible: (sysDelegate.modelData.sub || "") !== ""
                                    text: sysDelegate.modelData.sub || ""
                                    color: Theme.subtext
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 10
                                }
                            }

                            // Scale chips
                            Row {
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                visible: sysDelegate.modelData.type === "scale"
                                spacing: 4

                                Repeater {
                                    id: scaleRep
                                    property var entry: sysDelegate.modelData
                                    model: [1, 1.25, 1.5, 2]

                                    delegate: Rectangle {
                                        id: scaleChip
                                        required property var modelData
                                        property bool active: scaleRep.entry.monitor
                                            ? Math.abs(scaleRep.entry.monitor.scale - scaleChip.modelData) < 0.01
                                            : false
                                        width: 36; height: 22; radius: 3
                                        color: active ? Theme.blue : Theme.surface

                                        Text {
                                            anchors.centerIn: parent
                                            text: scaleChip.modelData % 1 === 0
                                                ? Math.round(scaleChip.modelData) + "×"
                                                : scaleChip.modelData + "×"
                                            color: active ? Theme.base : Theme.subtext
                                            font.family: "JetBrains Mono"
                                            font.pixelSize: 9
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (scaleRep.entry.monitor)
                                                    root.setMonitorScale(scaleRep.entry.monitor, scaleChip.modelData)
                                            }
                                        }
                                    }
                                }
                            }

                            // Stepper (+/value/−) for sensitivity and scroll_factor
                            Row {
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                visible: sysDelegate.modelData.type === "sensitivity" || sysDelegate.modelData.type === "scroll_factor"
                                spacing: 10

                                Text {
                                    text: "−"
                                    color: (sysDelegate.modelData.type === "sensitivity" && root.mouseSensitivity <= -1.0) ||
                                           (sysDelegate.modelData.type === "scroll_factor" && root.scrollFactor <= 0.1)
                                           ? Theme.surface : Theme.subtext
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 16
                                    verticalAlignment: Text.AlignVCenter
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: sysDelegate.modelData.type === "sensitivity"
                                            ? root.setMouseSensitivity(root.mouseSensitivity - 0.1)
                                            : root.setScrollFactor(root.scrollFactor - 0.05)
                                    }
                                }

                                Text {
                                    text: sysDelegate.modelData.type === "sensitivity"
                                        ? root.mouseSensitivity.toFixed(2)
                                        : root.scrollFactor.toFixed(2)
                                    color: Theme.text
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 12
                                    width: 44
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Text {
                                    text: "+"
                                    color: (sysDelegate.modelData.type === "sensitivity" && root.mouseSensitivity >= 1.0) ||
                                           (sysDelegate.modelData.type === "scroll_factor" && root.scrollFactor >= 3.0)
                                           ? Theme.surface : Theme.subtext
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 14
                                    verticalAlignment: Text.AlignVCenter
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: sysDelegate.modelData.type === "sensitivity"
                                            ? root.setMouseSensitivity(root.mouseSensitivity + 0.1)
                                            : root.setScrollFactor(root.scrollFactor + 0.05)
                                    }
                                }
                            }

                            // Toggle for natural_scroll
                            Text {
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                visible: sysDelegate.modelData.type === "natural_scroll"
                                text: root.naturalScroll ? "[*]" : "[ ]"
                                color: root.naturalScroll ? Theme.green : Theme.subtext
                                font.family: "JetBrains Mono"
                                font.pixelSize: 13
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.setNaturalScroll(!root.naturalScroll)
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onPositionChanged: mouse => {
                                    if (keyNav.hoverMoved(this, mouse.x, mouse.y))
                                        root.selectedIndex = sysDelegate.index
                                }
                                onClicked: keyNav.activateItem()
                            }
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width; height: 1
                            color: Theme.border; opacity: 0.3
                            visible: !sysDelegate.isSection
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
                    height: modelData.type === "math" ? 52
                          : (modelData.type === "wallpaper" || modelData.type === "app" || modelData.type === "bluetooth" || modelData.type === "layout") ? 56 : 44
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
                                color: modelData.type === "math" ? Theme.green
                                     : root.selectedSearchIndex === index ? Theme.text : Theme.subtext
                                font.family: "JetBrains Mono"
                                font.pixelSize: modelData.type === "math" ? 16 : 13
                                font.bold: modelData.type === "math"
                            }

                            Text {
                                text: (modelData.type === "design" || modelData.type === "layout") ? modelData.desc
                                    : modelData.type === "menu" ? "open menu"
                                    : modelData.type === "file" ? (modelData.isDir ? "directory" : "file")
                                    : modelData.type === "math" ? modelData.expr
                                    : modelData.type === "web"       ? "search the web"
                                    : modelData.type === "clipboard" ? "clipboard"
                                    : modelData.type
                                color: modelData.type === "wallpaper"  ? Theme.teal
                                     : modelData.type === "palette"    ? Theme.yellow
                                     : modelData.type === "bluetooth"  ? Theme.blue
                                     : modelData.type === "design"     ? Theme.purple
                                     : modelData.type === "layout"     ? Theme.teal
                                     : modelData.type === "menu"       ? Theme.purple
                                     : modelData.type === "file"       ? (modelData.isDir ? Theme.blue : Theme.subtext)
                                     : modelData.type === "math"       ? Theme.subtext
                                     : modelData.type === "web"        ? Theme.yellow
                                     : modelData.type === "clipboard"  ? Theme.teal
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

                    // Menu / directory arrow
                    Text {
                        anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                        visible: modelData.type === "menu" || (modelData.type === "file" && modelData.isDir)
                        text: ">"
                        color: Theme.subtext
                        font.family: "JetBrains Mono"
                        font.pixelSize: 12
                    }

                    // Math copy hint
                    Text {
                        anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                        visible: modelData.type === "math"
                        text: "copy"
                        color: Theme.subtext
                        font.family: "JetBrains Mono"
                        font.pixelSize: 10
                    }

                    // Web open hint
                    Text {
                        anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                        visible: modelData.type === "web"
                        text: "open"
                        color: Theme.yellow
                        font.family: "JetBrains Mono"
                        font.pixelSize: 10
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

                        // Pills design (5 small circles)
                        Row {
                            anchors.centerIn: parent
                            spacing: 2
                            visible: designPrev.res.type === "design" && designPrev.res.bars === 5
                            Repeater {
                                model: 5
                                Rectangle {
                                    width: 10
                                    height: designPrev.res.barH || 0
                                    radius: (designPrev.res.barH || 0) / 2
                                    color: Theme.subtext; opacity: 0.45
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onPositionChanged: mouse => { if (keyNav.hoverMoved(this, mouse.x, mouse.y)) root.selectedSearchIndex = index }
                        onClicked: keyNav.activateSearchItem()
                    }
                }
            }
        }
    }
}

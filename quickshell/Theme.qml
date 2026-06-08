pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string name:          "mocha"
    property string design:        "default"
    property int    barHeight:     30
    property int    barFontSize:   13
    property string barFontFamily: "JetBrains Mono"
    property bool   barFontBold:   false
    property string separatorText: "  │  "
    property bool showClock:      true
    property bool showBattery:    true
    property bool showCpu:        true
    property bool showMemory:     true
    property bool showAudio:      true
    property bool showBluetooth:  true
    property bool showNetwork:    true
    property bool showTray:       true
    property bool showWorkspaces: true
    property bool showMenu:       true
    property bool showGpu:        true
    property bool showMusic:      true
    property bool showInhibit:    true
    property int  gapsOut:        10

    property color base:    "#1e1e2e"
    property color surface: "#181825"
    property color border:  "#313244"
    property color text:    "#cdd6f4"
    property color subtext: "#6c7086"
    property color blue:    "#89b4fa"
    property color green:   "#a6e3a1"
    property color red:     "#f38ba8"
    property color yellow:  "#f9e2af"
    property color teal:    "#94e2d5"
    property color purple:  "#cba6f7"

    function applyPalette(n) {
        if (n === "macchiato") {
            base="#24273a"; surface="#1e2030"; border="#363a4f"
            text="#cad3f5"; subtext="#6e738d"
            blue="#8aadf4"; green="#a6da95"; red="#ed8796"
            yellow="#eed49f"; teal="#8bd5ca"; purple="#c6a0f6"
        } else if (n === "frappe") {
            base="#303446"; surface="#292c3c"; border="#414559"
            text="#c6d0f5"; subtext="#737994"
            blue="#8caaee"; green="#a6d189"; red="#e78284"
            yellow="#e5c890"; teal="#81c8be"; purple="#ca9ee6"
        } else if (n === "latte") {
            base="#eff1f5"; surface="#e6e9ef"; border="#ccd0da"
            text="#4c4f69"; subtext="#8c8fa1"
            blue="#1e66f5"; green="#40a02b"; red="#d20f39"
            yellow="#df8e1d"; teal="#179299"; purple="#8839ef"
        } else if (n === "tokyo-night") {
            base="#1a1b26"; surface="#16161e"; border="#292e42"
            text="#c0caf5"; subtext="#565f89"
            blue="#7aa2f7"; green="#9ece6a"; red="#f7768e"
            yellow="#e0af68"; teal="#73daca"; purple="#bb9af7"
        } else if (n === "gruvbox") {
            base="#282828"; surface="#1d2021"; border="#3c3836"
            text="#ebdbb2"; subtext="#928374"
            blue="#83a598"; green="#b8bb26"; red="#fb4934"
            yellow="#fabd2f"; teal="#8ec07c"; purple="#d3869b"
        } else if (n === "nord") {
            base="#2e3440"; surface="#3b4252"; border="#434c5e"
            text="#eceff4"; subtext="#4c566a"
            blue="#81a1c1"; green="#a3be8c"; red="#bf616a"
            yellow="#ebcb8b"; teal="#88c0d0"; purple="#b48ead"
        } else if (n === "dracula") {
            base="#282a36"; surface="#21222c"; border="#44475a"
            text="#f8f8f2"; subtext="#6272a4"
            blue="#6272a4"; green="#50fa7b"; red="#ff5555"
            yellow="#f1fa8c"; teal="#8be9fd"; purple="#bd93f9"
        } else if (n === "rosepine") {
            base="#191724"; surface="#1f1d2e"; border="#26233a"
            text="#e0def4"; subtext="#6e6a86"
            blue="#9ccfd8"; green="#31748f"; red="#eb6f92"
            yellow="#f6c177"; teal="#ebbcba"; purple="#c4a7e7"
        } else if (n === "onedark") {
            base="#282c34"; surface="#21252b"; border="#3e4451"
            text="#abb2bf"; subtext="#5c6370"
            blue="#61afef"; green="#98c379"; red="#e06c75"
            yellow="#e5c07b"; teal="#56b6c2"; purple="#c678dd"
        } else if (n === "everforest") {
            base="#2d353b"; surface="#232a2e"; border="#3d484d"
            text="#d3c6aa"; subtext="#7a8478"
            blue="#7fbbb3"; green="#a7c080"; red="#e67e80"
            yellow="#dbbc7f"; teal="#83c092"; purple="#d699b6"
        } else if (n === "solarized") {
            base="#002b36"; surface="#073642"; border="#586e75"
            text="#839496"; subtext="#657b83"
            blue="#268bd2"; green="#859900"; red="#dc322f"
            yellow="#b58900"; teal="#2aa198"; purple="#6c71c4"
        } else {
            // mocha (default)
            base="#1e1e2e"; surface="#181825"; border="#313244"
            text="#cdd6f4"; subtext="#6c7086"
            blue="#89b4fa"; green="#a6e3a1"; red="#f38ba8"
            yellow="#f9e2af"; teal="#94e2d5"; purple="#cba6f7"
        }
    }

    function applyDesign(d) {
        if (d === "compact") {
            barHeight = 24
            barFontFamily = "JetBrains Mono"; barFontBold = false
            separatorText = "  │  "
        } else if (d === "islands") {
            barHeight = 30
            barFontFamily = "JetBrains Mono"; barFontBold = false
            separatorText = "  │  "
        } else if (d === "bold") {
            barHeight = 40
            barFontFamily = "JetBrains Mono"; barFontBold = true
            separatorText = "  │  "
        } else if (d === "minimal") {
            barHeight = 18
            barFontFamily = "JetBrains Mono"; barFontBold = false
            separatorText = " · "
        } else if (d === "clean") {
            barHeight = 30
            barFontFamily = "Noto Sans"; barFontBold = false
            separatorText = "  /  "
        } else if (d === "hacker") {
            barHeight = 32
            barFontFamily = "Hack"; barFontBold = false
            separatorText = "  |  "
        } else if (d === "pills") {
            barHeight = 32
            barFontFamily = "JetBrains Mono"; barFontBold = false
            separatorText = "  │  "
        } else {
            // default
            barHeight = 30
            barFontFamily = "JetBrains Mono"; barFontBold = false
            separatorText = "  │  "
        }
    }

    Component.onCompleted: applyPalette(name)

    onNameChanged: {
        applyPalette(name)
        saveProc.command = ["sh", "-c", "mkdir -p \"$HOME/.config/quickshell\" && printf '%s' '" + name + "' > $HOME/.config/quickshell/theme"]
        saveProc.running = false
        saveProc.running = true
    }

    onDesignChanged: {
        applyDesign(design)
        saveDesignProc.command = ["sh", "-c", "mkdir -p \"$HOME/.config/quickshell\" && printf '%s' '" + design + "' > $HOME/.config/quickshell/design"]
        saveDesignProc.running = false
        saveDesignProc.running = true
    }

    function saveBarModules() {
        const data = JSON.stringify({
            showClock: root.showClock, showBattery: root.showBattery,
            showCpu: root.showCpu, showMemory: root.showMemory,
            showAudio: root.showAudio, showBluetooth: root.showBluetooth,
            showNetwork: root.showNetwork, showTray: root.showTray,
            showWorkspaces: root.showWorkspaces, showMenu: root.showMenu,
            showGpu: root.showGpu,
            showMusic: root.showMusic,
            showInhibit: root.showInhibit
        })
        const escaped = data.replace(/'/g, "'\\''")
        barModulesSaveProc.command = ["sh", "-c", "mkdir -p \"$HOME/.config/quickshell\" && printf '%s' '" + escaped + "' > $HOME/.config/quickshell/bar-modules"]
        barModulesSaveProc.running = false
        barModulesSaveProc.running = true
    }

    onShowClockChanged: saveBarModules()
    onShowBatteryChanged: saveBarModules()
    onShowCpuChanged: saveBarModules()
    onShowMemoryChanged: saveBarModules()
    onShowAudioChanged: saveBarModules()
    onShowBluetoothChanged: saveBarModules()
    onShowNetworkChanged: saveBarModules()
    onShowTrayChanged: saveBarModules()
    onShowWorkspacesChanged: saveBarModules()
    onShowMenuChanged: saveBarModules()
    onShowGpuChanged: saveBarModules()
    onShowMusicChanged: saveBarModules()
    onShowInhibitChanged: saveBarModules()

    onBarFontSizeChanged: {
        saveBarFontSizeProc.command = ["sh", "-c", "mkdir -p \"$HOME/.config/quickshell\" && printf '%s' '" + root.barFontSize + "' > $HOME/.config/quickshell/bar-font-size"]
        saveBarFontSizeProc.running = false
        saveBarFontSizeProc.running = true
    }

    Process { id: saveProc }
    Process { id: saveDesignProc }
    Process { id: barModulesSaveProc }
    Process { id: saveBarFontSizeProc }

    Process {
        id: loadProc
        command: ["sh", "-c", "cat $HOME/.config/quickshell/theme 2>/dev/null"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const saved = this.text.trim()
                if (saved) root.name = saved
            }
        }
    }

    Process {
        id: loadDesignProc
        command: ["sh", "-c", "cat $HOME/.config/quickshell/design 2>/dev/null"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const saved = this.text.trim()
                if (saved) root.design = saved
            }
        }
    }

    Process {
        id: loadBarFontSizeProc
        command: ["sh", "-c", "cat $HOME/.config/quickshell/bar-font-size 2>/dev/null"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const saved = this.text.trim()
                if (saved) {
                    const val = parseInt(saved, 10)
                    if (!isNaN(val)) root.barFontSize = val
                }
            }
        }
    }

    Process {
        id: loadBarModulesProc
        command: ["sh", "-c", "cat $HOME/.config/quickshell/bar-modules 2>/dev/null"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const saved = this.text.trim()
                if (saved) {
                    try {
                        const obj = JSON.parse(saved)
                        if (obj.showClock !== undefined) root.showClock = obj.showClock
                        if (obj.showBattery !== undefined) root.showBattery = obj.showBattery
                        if (obj.showCpu !== undefined) root.showCpu = obj.showCpu
                        if (obj.showMemory !== undefined) root.showMemory = obj.showMemory
                        if (obj.showAudio !== undefined) root.showAudio = obj.showAudio
                        if (obj.showBluetooth !== undefined) root.showBluetooth = obj.showBluetooth
                        if (obj.showNetwork !== undefined) root.showNetwork = obj.showNetwork
                        if (obj.showTray !== undefined) root.showTray = obj.showTray
                        if (obj.showWorkspaces !== undefined) root.showWorkspaces = obj.showWorkspaces
                        if (obj.showMenu !== undefined) root.showMenu = obj.showMenu
                        if (obj.showGpu !== undefined) root.showGpu = obj.showGpu
                        if (obj.showMusic !== undefined) root.showMusic = obj.showMusic
                        if (obj.showInhibit !== undefined) root.showInhibit = obj.showInhibit
                    } catch(e) {}
                }
            }
        }
    }
}

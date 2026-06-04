pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string name: "mocha"

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
        } else {
            // mocha (default)
            base="#1e1e2e"; surface="#181825"; border="#313244"
            text="#cdd6f4"; subtext="#6c7086"
            blue="#89b4fa"; green="#a6e3a1"; red="#f38ba8"
            yellow="#f9e2af"; teal="#94e2d5"; purple="#cba6f7"
        }
    }

    // Apply after full construction so all properties are ready
    Component.onCompleted: applyPalette(name)

    onNameChanged: {
        applyPalette(name)
        saveProc.command = ["sh", "-c", "printf '%s' '" + name + "' > $HOME/.config/quickshell/theme"]
        saveProc.running = false
        saveProc.running = true
    }

    Process { id: saveProc }

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
}

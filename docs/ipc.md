---
layout: home
title: IPC & Shell Root
---

# IPC & Shell Root

`shell.qml` is the root of the Quickshell process. It owns all global state and exposes IPC targets that Hyprland keybinds and shell scripts call into.

---

## User Guide

Keybinds in `hyprland.lua` use Quickshell's IPC to trigger shell actions:

| Keybind | IPC call |
|---|---|
| `Alt + S` | `qs ipc call settings toggle` |
| `Alt + Space` | `quickshell ipc -c default call settings openApps` |
| `Alt + D` | `qs ipc call statusbar toggle` |
| `Alt + Delete` | `qs ipc call lock lock` |
| `Alt + R` | runs `random-wallpaper.sh` which calls `qs ipc call theme setCustom` |

---

## Internals

**File:** `quickshell/shell.qml`

### IpcHandlers

Each feature exposes a named `IpcHandler` target:

```qml
IpcHandler { target: "settings"
    function toggle()    { root.settingsOpen = !root.settingsOpen }
    function open()      { root.settingsOpen = true }
    function openApps()  { root.requestedPage = "apps"; root.settingsOpen = true }
    function close()     { root.settingsOpen = false }
}

IpcHandler { target: "lock"
    function lock() { root.sessionLocked = true; lockScreen.lock() }
}

IpcHandler { target: "statusbar"
    function toggle() { root.barVisible = !root.barVisible }
    function show()   { root.barVisible = true }
    function hide()   { root.barVisible = false }
}

IpcHandler { target: "theme"
    function setCustom() { Theme.loadCustomPalette() }
}

IpcHandler { target: "clipboard"
    function copied() { root.clipboardCopied() }
}
```

These are called from the command line with:
```bash
qs ipc -c default call <target> <function>
```

### Global State

```qml
property bool settingsOpen: false
property string requestedPage: "main"
property bool sessionLocked: false
property bool barVisible: true
```

`settingsOpen` and `barVisible` are bound to the `SettingsWindow` and `PanelWindow` respectively.

### Clipboard Watcher

A long-running `Process` polls the clipboard every 500ms and calls `clipboard copied` via IPC to flash the clipboard notification in the bar:

```qml
Process {
    command: ["sh", "-c",
        "last=''; while sleep 0.5; do current=$(wl-paste 2>/dev/null); " +
        "if [ \"$current\" != \"$last\" ] && [ -n \"$current\" ]; then " +
        "quickshell ipc -c default call clipboard copied; last=\"$current\"; fi; done"]
    running: true
}
```

This detects new clipboard content and triggers a `✓ copied` flash in the bar center.

### awww-daemon Watchdog

A `Process` at startup ensures `awww-daemon` is running (required for wallpaper transitions):

```qml
Process {
    command: ["sh", "-c", "pgrep -x awww-daemon > /dev/null || awww-daemon"]
    running: true
}
```

---

[← Settings Overlay](settings-overlay.html) • [Home →](index.html)

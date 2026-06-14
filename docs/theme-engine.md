---
layout: home
title: Theme Engine
---

# Theme Engine

The theme engine provides live-animated color transitions, 18 built-in palettes, custom palette support, and system-wide color syncing.

---

## User Guide

### Switching Palettes

Open **Settings → Appearance** and select any palette. The transition animates over 500ms.

### Available Palettes

**Dark:** Catppuccin Mocha (default), Macchiato, Frappe, Tokyo Night, Gruvbox, Nord, Dracula, Rose Pine, One Dark, Everforest, Solarized Dark

**Light:** Catppuccin Latte, Solarized Light, Gruvbox Light, Nord Light, Rose Pine Dawn, One Light

### System Sync

Every palette change automatically updates:
- **Kitty** - via `update-kitty-colors.sh` over Unix sockets
- **Firefox** - via pywalfox (if installed)
- **GTK** - writes `~/.config/gtk-3.0/settings.ini` and `gtk-4.0/settings.ini` with `gtk-application-prefer-dark-theme`
- **Qt/Dolphin** - writes a qt6ct color scheme via `kwriteconfig6`

### Bar Designs

The theme also controls the bar's visual style. `Theme.design` is read by `shell.qml` to determine layout, background colors, and radius.

---

## Internals

**File:** `quickshell/Theme.qml`

### Singleton Architecture

`Theme.qml` is a `pragma Singleton` - a single instance shared across all QML files. Any file can read `Theme.base`, `Theme.accent`, etc. directly without passing references.

### Animated Color Properties

Every color property has a `Behavior` that animates transitions:

```qml
property color blue: "#89b4fa"
Behavior on blue { ColorAnimation { duration: 500; easing.type: Easing.OutCubic } }
```

When `applyPalette("nord")` is called, all 11 color properties update simultaneously and animate to their new values over 500ms.

### Target Colors

Rapid palette switches would send intermediate animated color values to Kitty/Firefox if using the animated properties directly. To avoid this, a `_target` object stores the intended final values:

```qml
property var _target: ({ base: "#1e1e2e", ... })
```

`applyPalette` sets `_target` first, then sets the animated properties. External sync scripts always read from `_target`.

### Palette Application

```qml
function applyPalette(n) {
    let b, sf, bo, tx, sx, bl, gn, rd, ye, te, pu
    if (n === "nord") {
        b="#2e3440"; sf="#3b4252"; ...
    }
    // ... 17 more palette branches
    root._target = { base: b, ... }
    base = b; surface = sf; ...
}
```

Each palette defines 11 values: `base`, `surface`, `border`, `text`, `subtext`, `blue`, `green`, `red`, `yellow`, `teal`, `purple`.

### Custom Palette

`loadCustomPalette()` reads `~/.config/quickshell/custom-palette` (written by `extract-palette.py`) and parses the 11 space-separated hex values:

```qml
function loadCustomPalette() {
    customPaletteProc.running = true
}
Process {
    id: customPaletteProc
    command: ["cat", homeDir + "/.config/quickshell/custom-palette"]
    stdout: StdioCollector {
        onStreamFinished: {
            const parts = this.text.trim().split(" ")
            // assign to base, surface, border, text, subtext, blue, green, red, yellow, teal, purple
        }
    }
}
```

### Design and Layout

`Theme.design` drives visual changes in `shell.qml`:
- Bar background color (`transparent` for islands/pills, `Theme.base` otherwise)
- Island `Rectangle` visibility
- Pill background shapes
- Separator visibility
- `exclusiveZone` height calculations

`applyDesign(d)` sets `barHeightPadding`, `barFontFamily`, `barFontBold`, and `separatorText`.

### Kitty Color Sync

`update-kitty-colors.sh` iterates `/tmp/kitty-*` Unix sockets and sends a color update to each live Kitty instance using Kitty's remote control protocol (`kitty @ --to unix:... set-colors`). This means all open terminals update instantly without restart.

---

[← IPC & Shell Root](ipc.html) • [Palette Extraction →](palette-extraction.html)

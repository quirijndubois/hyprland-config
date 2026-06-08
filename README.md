# Hyprland Config

A personal [Hyprland](https://hyprland.org) desktop setup with a custom [Quickshell](https://quickshell.outfoxxed.me/) shell — keyboard-driven, visually cohesive, and easy to tweak.

![demo](demo.gif)

## Features

- **Quickshell bar** — modular panel with workspaces, system stats (CPU, memory, battery), clock, audio, network, Bluetooth, and system tray
- **Notification system** — quickshell acts as the D-Bus notification daemon. Incoming notifications animate the center workspace pill: workspace numbers fade out, the pill widens, and the app name + summary appear for 5 seconds before fading back. Hover the workspace section to see a popup with the 5 most recent notifications (with per-item dismiss and clear-all). Full history is in the settings overlay under *notifications*.
- **Settings overlay** — press `Alt+S` to open a floating settings window with fuzzy search across wallpapers, color palettes, bar designs, layouts, and apps. Reorder the main menu with `Shift+Up`/`Shift+Down` (persisted across restarts)
- **Filesystem browser** — type any absolute path (e.g. `/home/q/`) in the fuzzy finder to list that directory; navigate into subdirectories with Enter, open files with `xdg-open`, backspace to go back up
- **Math evaluator** — type an arithmetic expression (`5 * (3 + 2)`, `2^16`, `(100 - 32) / 1.8`) to evaluate it inline; press Enter to copy the result to the clipboard
- **Web search fallback** — if the fuzzy search returns no results, a single entry appears to open the query in DuckDuckGo
- **12 color palettes** — Catppuccin, Tokyo Night, Gruvbox, Nord, Dracula, Rose Pine, One Dark, Everforest, Solarized, and more — switch on the fly
- **8 bar designs** — default, compact, islands (floating pills), pills (per-module pill chips on a transparent bar), bold, minimal, clean (sans-serif), and hacker
- **4 Hyprland layouts** — dwindle, master, spiral, and split — toggleable from settings
- **Wallpaper manager** — browse and apply wallpapers with smooth `awww` transitions, per-monitor support
- **App launcher** — browse and launch apps from the settings overlay
- **Bluetooth manager** — pair, connect, and disconnect devices from settings
- **Clipboard history** — browse and re-copy previous clipboard entries via the settings overlay; also searchable from the fuzzy finder
- **Lua config** — modern Hyprland Lua format with custom bezier animations, blur, shadows, and rounded corners

## Keybinds

| Key | Action |
|---|---|
| `Alt + Q` | Open terminal (kitty) |
| `Alt + Space` | Open app launcher (settings apps page) |
| `Alt + S` | Toggle settings overlay |
| `Alt + W` | Close window |
| `Alt + F` | Toggle fullscreen |
| `Alt + V` | Toggle float |
| `Alt + E` | File manager (dolphin) |
| `Alt + T` | Browser (firefox) |
| `Alt + Tab` | Cycle workspaces |
| `Alt + Shift + Tab` | Cycle workspaces backward |
| `Alt + 1–9 / 0` | Switch to workspace |
| `Alt + Shift + 1–9 / 0` | Move window to workspace |
| `Alt + Shift + C` | Region screenshot |

## Installation

### 1. Install dependencies

```bash
# Arch Linux
paru -S hyprland quickshell-git kitty awww hyprlock hypridle hyprshot hyprpicker wl-clipboard cliphist
```

> **Do not install dunst.** Quickshell registers itself as the `org.freedesktop.Notifications` D-Bus service. If dunst is already installed and its systemd unit is active, it will claim that name first and quickshell won't receive notifications. Mask it to prevent this:
> ```bash
> systemctl --user mask dunst
> ```

### 2. Clone and run the install script

```bash
git clone https://github.com/yourusername/hyprland-config.git
cd hyprland-config
./install.sh
```

This syncs configs for `hypr`, `kitty`, and `quickshell` to `~/.config/`. Use `--watch` to auto-reload on file changes:

```bash
./install.sh --watch
```

### 3. Wallpapers

Drop images into `wallpapers/` — they appear immediately in the settings wallpaper picker.

## Requirements

- [Hyprland](https://hyprland.org)
- [Quickshell](https://quickshell.outfoxxed.me/) (built from git — `quickshell-git` on AUR)
- [kitty](https://sw.kovidgoyal.net/kitty/)
- [awww](https://github.com/danyspin97/awww) (wallpaper transitions)
- [hyprlock](https://github.com/hyprwm/hyprlock) / [hypridle](https://github.com/hyprwm/hypridle) (lockscreen + idle)
- [hyprshot](https://github.com/Gustash/hyprshot) (screenshots)
- [hyprpicker](https://github.com/hyprwm/hyprpicker) (color picker)
- [wl-clipboard](https://github.com/bugaevc/wl-clipboard) (clipboard history)
- [cliphist](https://github.com/sentriz/cliphist) (clipboard history)

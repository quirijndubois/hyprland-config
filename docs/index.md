---
layout: home
title: Qaskade
---

# Qaskade

A keyboard-driven [Hyprland](https://hyprland.org) desktop shell powered by [Quickshell](https://quickshell.outfoxxed.me/). Visually cohesive, feature-packed, and blazingly fast.

![Demo](https://github.com/quirijn/qaskade/raw/main/demo.gif)

## Features

### Custom Quickshell Panel
- **Modular bar** - workspaces, clock, battery, CPU (per-core), GPU (NVIDIA), memory, audio, network, Bluetooth, MPRIS music player, system tray, and sleep inhibit - each independently toggleable
- **Hover popups** - every module shows rich info on hover (CPU per-core chart + top processes, GPU utilization + VRAM, memory bar + top processes, per-app audio sliders with live peak meters, battery time remaining, music controls with seek bar, network IP/SSID, Bluetooth device list, and more)
- **Notification center** - the workspace pill animates on incoming notifications. Hover it for the 5 most recent notifications with per-item dismiss and clear-all. Full history in settings.
- **MPRIS music visualization** - animated dancing bars when music plays, with progress bar, seek, and transport controls
- **System tray** - any StatusNotifierItem app

### Settings Overlay (`Alt+S`)
- **Fuzzy search** across wallpapers, palettes, designs, layouts, bar modules, apps, Bluetooth devices, clipboard history, monitors, and system settings
- **Appearance page** - select palettes, bar designs, lock screen designs, and toggle individual bar modules
- **Monitor layout page** - enable/disable monitors, set resolution/scale/position, assign workspaces
- **System settings page** - adjust monitor scales, mouse sensitivity, natural scroll, scroll factor, window layout
- **Filesystem browser** - navigate directories and open files with `xdg-open`
- **Math evaluator** - type expressions like `5 * (3 + 2)` or `2^16` and get instant results
- **Keyboard-driven** - full navigation with arrows, Enter, Escape; reorder menu with `Shift+Up`/`Shift+Down`

### Theming & Layout
- **18 color palettes** - Dark: Catppuccin Mocha/Macchiato/Frappe, Tokyo Night, Gruvbox, Nord, Dracula, Rose Pine, One Dark, Everforest, Solarized Dark. Light: Catppuccin Latte, Solarized Light, Gruvbox Light, Nord Light, Rose Pine Dawn, One Light
- **Smooth transitions** - switch themes with animated 500ms transitions, live synced to Kitty, Firefox, and system dark/light mode
- **Wallpaper extraction** - press `A` on any wallpaper to automatically extract dominant colors and apply them system-wide
- **Random wallpaper** - `Alt+R` picks a random wallpaper with animated transition and applies extracted palette
- **8 bar designs** - default, compact, islands, pills, bold, minimal, clean, hacker
- **4 Hyprland layouts** - dwindle, master, scrolling, monocle
- **Custom animations** - 5 hand-tuned bezier curves for windows, workspaces, fade, and layers
- **Adjustable bar font size** - customize text size while maintaining proportions

### System Management
- **Monitor layout** - configure position, resolution, scale, and enable/disable monitors
- **Wallpaper manager** - browse and apply images with smooth transitions (fade, slide, wipe, wave, grow)
- **App launcher** - browse `.desktop` entries with icons
- **Bluetooth manager** - pair, connect, disconnect devices from settings
- **Clipboard history** - browse and re-copy entries via `cliphist`
- **System settings** - live configuration via `hyprctl` and persistent `user-settings.lua`

### Lock Screen
- **Wayland session lock** - password auth via `unix_chkpwd`. Lock with `Alt+Delete`.
- **5 designs** - default, minimal, clock, terminal, split, plus random mode
- **Typing animations** - each dot slides in from the previous dot; password box pulses on keystroke

## Installation

### 1. Install dependencies

```bash
# Arch Linux - official repos
sudo pacman -S hyprland kitty awww hypridle hyprshot hyprpicker wl-clipboard cliphist kconfig

# AUR
paru -S quickshell-git
```

> **Note:** Do not install dunst. Quickshell registers itself as the `org.freedesktop.Notifications` D-Bus service. Mask dunst if installed:
> ```bash
> systemctl --user mask dunst
> ```

### 2. Clone and run the install script

```bash
git clone https://github.com/quirijn/qaskade.git
cd qaskade
./install.sh
```

Use `--watch` to auto-reload on file changes:
```bash
./install.sh --watch
```

### 3. Firefox color sync (optional)

Install [pywalfox](https://github.com/Frewacom/pywalfox) for live palette updates in Firefox:

```bash
conda create -n pywalfox python=3.11 -y
conda run -n pywalfox pip install pywalfox Pillow
conda run -n pywalfox pywalfox install
```

Then install the [Firefox extension](https://addons.mozilla.org/firefox/addon/pywalfox/).

### 4. Wallpapers

Drop images into `wallpapers/` - they appear immediately in the settings wallpaper picker.

## Keybinds

| Key | Action |
|---|---|
| `Alt + Q` | Open terminal (kitty) |
| `Alt + Space` | Open app launcher |
| `Alt + S` | Toggle settings overlay |
| `Alt + D` | Toggle status bar visibility |
| `Alt + W` | Close window |
| `Alt + F` | Toggle fullscreen |
| `Alt + V` | Toggle float |
| `Alt + E` | File manager (dolphin) |
| `Alt + T` | Browser (firefox) |
| `Alt + Delete` | Lock screen |
| `Alt + Tab` | Cycle workspaces |
| `Alt + Shift + Tab` | Cycle workspaces backward |
| `Alt + 1–9 / 0` | Switch to workspace |
| `Alt + Shift + 1–9 / 0` | Move window to workspace |
| `Alt + H / J / K / L` | Focus left / down / up / right |
| `Alt + Shift + H / J / K / L` | Move window |
| `Alt + Ctrl + H / J / K / L` | Resize window |
| `Alt + I` | Toggle split layout |
| `Alt + R` | Random wallpaper + extracted palette |
| `Alt + C` | Color picker (hyprpicker) |
| `Alt + Shift + C` | Region screenshot |
| `Alt + = / -` | Zoom in / out |
| `Alt + 0` | Reset zoom |

## Requirements

- [Hyprland](https://hyprland.org)
- [Quickshell](https://quickshell.outfoxxed.me/) (built from git)
- [Kitty](https://sw.kovidgoyal.net/kitty/)
- [awww](https://github.com/danyspin97/awww) - wallpaper transitions
- [hypridle](https://github.com/hyprwm/hypridle) - idle management
- [hyprshot](https://github.com/Gustash/hyprshot) - screenshots
- [hyprpicker](https://github.com/hyprwm/hyprpicker) - color picker
- [wl-clipboard](https://github.com/bugaevc/wl-clipboard) - clipboard management
- [cliphist](https://github.com/sentriz/cliphist) - clipboard history

## License

Qaskade is licensed under the [GNU General Public License v3.0](https://github.com/quirijn/qaskade/blob/main/LICENSE)

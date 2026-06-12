# Qaskade

A [Hyprland](https://hyprland.org) desktop shell powered by a custom [Quickshell](https://quickshell.outfoxxed.me/) panel. Keyboard-driven, visually cohesive, and packed with tools.

![demo](demo.gif)

## Features

### Custom Quickshell Panel
- **Modular bar** - workspaces, clock, battery, CPU (per-core), GPU (NVIDIA), memory, audio, network, Bluetooth, MPRIS music player, system tray, and sleep inhibit - each independently toggleable
- **Hover popups** - every module shows a rich info popup on hover (CPU per-core chart + top processes, GPU utilization + VRAM, memory bar + top processes, per-app audio sliders with live peak meters, battery time remaining, music controls with seek bar, network IP/SSID, Bluetooth device list, and more)
- **Notification center** - the workspace pill animates on incoming notifications (widens, shows app + summary for 5s). Hover it for the 5 most recent notifications with per-item dismiss and clear-all. Full history in settings.
- **MPRIS music visualization** - animated dancing bars when music plays, with progress bar, seek, and transport controls
- **System tray** - Discord, Telegram, and any StatusNotifierItem app

### Settings Overlay (`Alt+S`)
- **Fuzzy search** across wallpapers, palettes, designs, layouts, bar modules, apps, Bluetooth devices, clipboard history, monitors, and system settings
- **Appearance page** - select palettes, bar designs, and toggle individual bar modules (menu, clock, battery, CPU, memory, GPU, workspaces, music, audio, Bluetooth, network, sleep inhibit, tray)
- **Monitor layout page** - enable/disable monitors, set resolution/scale/position, assign workspaces to specific monitors
- **System settings page** - adjust monitor scales, mouse sensitivity, natural scroll, scroll factor, window layout (dwindle/master/scrolling/monocle)
- **Notification history** - view recent notifications, manually dismiss, or clear all
- **Filesystem browser** - type any absolute path to browse directories, open files with `xdg-open`
- **Math evaluator** - type `5 * (3 + 2)`, `2^16`, `(100 - 32) / 1.8` - evaluates inline, copies result with Enter
- **Web search fallback** - no results? Opens your query in DuckDuckGo
- **Keyboard-driven** - full navigation with arrows, Enter, Escape; reorder the main menu with `Shift+Up`/`Shift+Down` (persisted)

### Theming & Layout
- **12 color palettes** - Catppuccin (mocha, macchiato, frappe, latte), Tokyo Night, Gruvbox, Nord, Dracula, Rose Pine, One Dark, Everforest, Solarized Dark - switch instantly with live Kitty terminal color sync
- **8 bar designs** - default, compact, islands (floating pills), pills (per-module chips on a transparent bar), bold, minimal, clean (sans-serif), hacker
- **4 Hyprland layouts** - dwindle, master, scrolling, monocle - toggle from settings, applies live
- **Custom bezier animations** - 5 hand-tuned curves for windows, workspaces, fade, and layers
- **Bar module toggles** - independently show/hide menu, clock, battery, CPU, memory, GPU, workspaces, music, audio, Bluetooth, network, sleep inhibit, and system tray
- **Adjustable bar font size** - customize text size while maintaining bar proportions

### System Management
- **Monitor layout** - configure position, resolution, scale, and enable/disable monitors; assign workspaces to specific monitors
- **Wallpaper manager** - browse and apply images with smooth `awww` transitions (fade, slide, wipe, wave, grow, and more), per-monitor
- **App launcher** - browse `.desktop` entries with icons, launch from the settings overlay
- **Bluetooth manager** - pair, connect, disconnect devices - all from settings
- **Clipboard history** - browse and re-copy entries via `cliphist`; searchable from fuzzy finder
- **System settings** - monitor scale/resolution, enable/disable monitors, mouse sensitivity, natural scroll, scroll factor - applied live via `hyprctl` and persisted to `user-settings.lua`

### Lock Screen
- **Wayland session lock** - centered clock + date, password auth via `unix_chkpwd`, blur background. Lock with `Alt+Delete`.

### Input & Gestures
- **3-finger swipe** - horizontal gesture switches workspaces
- **Cursor zoom** - `Alt+=` / `Alt+-` to zoom, `Alt+0` to reset
- **Multimedia keys** - volume, brightness, mic mute, media playback

### Config
- **Hyprland Lua** - modern `hyprland.lua` with custom bezier curves, blur, shadows, rounded corners, and user-settings override (`~/.config/hypr/user-settings.lua` not tracked by git)

## Keybinds

| Key | Action |
|---|---|
| `Alt + Q` | Open terminal (kitty) |
| `Alt + Space` | Open app launcher (settings apps page) |
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
| `Alt + C` | Color picker (hyprpicker) |
| `Alt + Shift + C` | Region screenshot |
| `Alt + = / -` | Zoom in / out |
| `Alt + 0` | Reset zoom |

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
git clone https://github.com/quirijn/qaskade.git
cd qaskade
./install.sh
```

This syncs configs for `hypr`, `kitty`, and `quickshell` to `~/.config/`. Use `--watch` to auto-reload on file changes:

```bash
./install.sh --watch
```

### 3. Wallpapers

Drop images into `wallpapers/` - they appear immediately in the settings wallpaper picker.

## Requirements

- [Hyprland](https://hyprland.org)
- [Quickshell](https://quickshell.outfoxxed.me/) (built from git - `quickshell-git` on AUR)
- [kitty](https://sw.kovidgoyal.net/kitty/)
- [awww](https://github.com/danyspin97/awww) (wallpaper transitions)
- [hyprlock](https://github.com/hyprwm/hyprlock) / [hypridle](https://github.com/hyprwm/hypridle) (lockscreen + idle)
- [hyprshot](https://github.com/Gustash/hyprshot) (screenshots)
- [hyprpicker](https://github.com/hyprwm/hyprpicker) (color picker)
- [wl-clipboard](https://github.com/bugaevc/wl-clipboard) (clipboard history)
- [cliphist](https://github.com/sentriz/cliphist) (clipboard history)

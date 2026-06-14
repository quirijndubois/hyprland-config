# Qaskade

A [Hyprland](https://hyprland.org) desktop shell powered by a custom [Quickshell](https://quickshell.outfoxxed.me/) panel. Keyboard-driven, visually cohesive, and packed with tools.

**[📖 View the full documentation](https://quirijndubois.github.io/qaskade/)**

![demo](demo.gif)

## Features

### Custom Quickshell Panel
- **Modular bar** - workspaces, clock, battery, CPU (per-core), GPU (NVIDIA), memory, audio, network, Bluetooth, MPRIS music player, system tray, and sleep inhibit - each independently toggleable
- **Hover popups** - every module shows a rich info popup on hover (CPU per-core chart + top processes, GPU utilization + VRAM, memory bar + top processes, per-app audio sliders with live peak meters, battery time remaining, music controls with seek bar, network IP/SSID, Bluetooth device list, and more)
- **Notification center** - the workspace pill animates on incoming notifications (widens, shows app + summary for 5s). Hover it for the 5 most recent notifications with per-item dismiss and clear-all. Full history in settings.
- **MPRIS music visualization** - animated dancing bars when music plays, with progress bar, seek, and transport controls
- **System tray** - any StatusNotifierItem app

### Settings Overlay (`Alt+S`)
- **Fuzzy search** across wallpapers, palettes, designs, layouts, bar modules, apps, Bluetooth devices, clipboard history, monitors, and system settings
- **Appearance page** - select palettes, bar designs, lock screen designs, and toggle individual bar modules (menu, clock, battery, CPU, memory, GPU, workspaces, music, audio, Bluetooth, network, sleep inhibit, tray); in the wallpaper picker press `A` to extract a palette directly from the image
- **Monitor layout page** - enable/disable monitors, set resolution/scale/position, assign workspaces to specific monitors
- **System settings page** - adjust monitor scales, mouse sensitivity, natural scroll, scroll factor, window layout (dwindle/master/scrolling/monocle)
- **Notification history** - view recent notifications, manually dismiss, or clear all
- **Filesystem browser** - type any absolute path to browse directories, open files with `xdg-open`
- **Math evaluator** - type `5 * (3 + 2)`, `2^16`, `(100 - 32) / 1.8` - evaluates inline, copies result with Enter
- **Web search fallback** - no results? Opens your query in DuckDuckGo
- **Keyboard-driven** - full navigation with arrows, Enter, Escape; reorder the main menu with `Shift+Up`/`Shift+Down` (persisted)

### Theming & Layout
- **18 color palettes** split into dark and light groups - Dark: Catppuccin Mocha/Macchiato/Frappe, Tokyo Night, Gruvbox, Nord, Dracula, Rose Pine, One Dark, Everforest, Solarized Dark. Light: Catppuccin Latte, Solarized Light, Gruvbox Light, Nord Light, Rose Pine Dawn, One Light - switch with smooth 500ms animated transitions and live sync to Kitty, Firefox, and system dark/light mode (GTK3/4 apps, Qt/Dolphin via qt6ct)
- **Wallpaper palette extraction** — press `A` on any wallpaper to automatically extract its dominant colors and apply them as a live palette across the shell, Kitty, Firefox, and system dark mode; palette is WCAG-contrast-enforced (text ≥ 7:1, accents ≥ 4.5:1) and randomized so each extraction differs
- **Random wallpaper shortcut** — `Alt+R` picks a random wallpaper from `~/wallpapers/`, applies it with a random animated transition, and immediately extracts and applies its color palette system-wide
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
- **System settings** - monitor scale/resolution, enable/disable monitors, mouse sensitivity, natural scroll, scroll factor, blur toggle - applied live via `hyprctl` and persisted to `user-settings.lua`
- **Blur toggle** - enable/disable Hyprland compositor blur from settings; automatically sets Kitty terminal background opacity to 1.0 when blur is off and restores it when blur is back on

### Lock Screen
- **Wayland session lock** - password auth via `unix_chkpwd`. Lock with `Alt+Delete`.
- **5 designs** - default (clock + date + username), minimal (floating dots only), clock (oversized 164px time face), terminal (console-style prompt card), split (time left, input right) — plus a **random** mode that picks a different design on every lock
- **Typing animations** - each dot slides in from the previous dot's position; the password box pulses on every keystroke; wrong password triggers a damped horizontal shake
- **Design persists** across restarts; switch from Settings → Appearance → lock screen

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
| `Alt + R` | Random wallpaper + extracted color palette |
| `Alt + C` | Color picker (hyprpicker) |
| `Alt + Shift + C` | Region screenshot |
| `Alt + = / -` | Zoom in / out |
| `Alt + 0` | Reset zoom |

## Installation

### 1. Install dependencies

```bash
# Arch Linux - official repos
sudo pacman -S hyprland kitty awww hypridle hyprshot hyprpicker wl-clipboard cliphist kconfig

# AUR
paru -S quickshell-git
```

`kconfig` provides `kwriteconfig6`, used to update the qt6ct color scheme when the palette changes.

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

### 3. Firefox color sync (optional)

Palette changes can update Firefox in real-time using [pywalfox](https://github.com/Frewacom/pywalfox).

**a. Install the native messaging host in a dedicated conda environment:**

```bash
conda create -n pywalfox python=3.11 -y
conda run -n pywalfox pip install pywalfox Pillow
conda run -n pywalfox pywalfox install
```

This installs the daemon to `~/.conda/envs/pywalfox/bin/pywalfox` and the Python interpreter used by `quickshell/extract-palette.py` for wallpaper palette extraction — both paths are used by `quickshell/Theme.qml` and `quickshell/SettingsWindow.qml`.

**b. Install the Firefox extension:**

[addons.mozilla.org/firefox/addon/pywalfox](https://addons.mozilla.org/firefox/addon/pywalfox/)

**c. Restart Firefox.**

After that, palette changes in the settings overlay automatically update Firefox with no further interaction needed.

> **Note:** System dark/light mode (GTK apps, Dolphin, other Qt apps) updates immediately for new app launches. Running Qt apps need a restart to pick up the new color scheme; GTK apps respond live via `settings.ini`.

### 4. Wallpapers

Drop images into `wallpapers/` - they appear immediately in the settings wallpaper picker.

## Requirements

- [Hyprland](https://hyprland.org)
- [Quickshell](https://quickshell.outfoxxed.me/) (built from git - `quickshell-git` on AUR)
- [kitty](https://sw.kovidgoyal.net/kitty/)
- [awww](https://github.com/danyspin97/awww) (wallpaper transitions)
- [hypridle](https://github.com/hyprwm/hypridle) (idle management)
- [hyprshot](https://github.com/Gustash/hyprshot) (screenshots)
- [hyprpicker](https://github.com/hyprwm/hyprpicker) (color picker)
- [wl-clipboard](https://github.com/bugaevc/wl-clipboard) (clipboard history)
- [cliphist](https://github.com/sentriz/cliphist) (clipboard history)

---
layout: home
title: Configuration
---

# Configuration

Qaskade syncs three config directories to `~/.config/`:

- `hypr/` → Hyprland configuration (Lua)
- `kitty/` → Kitty terminal configuration
- `quickshell/` → Quickshell shell and settings

## Hyprland Configuration (`hyprland.lua`)

The Hyprland config is written in Lua and controls:

- **Monitors** - Define outputs, resolution, position, scale
- **Workspaces** - Assign workspaces to specific monitors
- **Autostart** - Programs to launch on session start
- **Window rules** - Floating, pinning, repositioning windows
- **Animations** - Custom bezier curves for smoothness
- **Layout settings** - dwindle, master, scrolling, monocle
- **Appearance** - Gaps, shadows, blur, rounding, borders

### User Overrides

Create `~/.config/hypr/user-settings.lua` for system-specific customizations (not tracked by git). This file is loaded after the main config and can override any settings.

### Autostart Programs

Edit the `hl.on("hyprland.start", ...)` block to customize which programs launch at startup. Current autostart:
- kitty with hyfetch
- quickshell
- solaar (Logitech mouse config)
- hypridle (idle/sleep management)
- awww-daemon (wallpaper transitions)
- wl-paste for clipboard history

## Hypridle Configuration (`hypridle.conf`)

Controls idle behavior:

- `timeout` - Seconds before triggering the action
- `on-timeout` - Command to run when timeout is reached
- `on-resume` - Command to run when activity resumes

Default timeouts:
- 300s (5m) - Disable displays and peripherals
- 1000s (17m) - Lock screen

## Kitty Configuration

Minimal config that relies on system-wide color syncing. The settings overlay automatically updates Kitty colors when themes change.

## Quickshell Configuration

The `~/.config/quickshell/` directory contains:

- **Theme settings** - Current palette, design, lock screen design, bar font size
- **main-items** - Order of items in the settings menu (editable via `Shift+Up`/`Shift+Down`)
- **Custom palette** - Auto-extracted from wallpapers
- **user-settings.lua** - System-specific overrides (not tracked)

### Per-Module Configuration

Each bar module has toggle options in the Settings overlay (Alt+S → Appearance):

- Menu, Clock, Battery, CPU, Memory, GPU
- Workspaces, Music, Audio
- Bluetooth, Network, Sleep Inhibit, System Tray

These are persisted automatically.

## Watch Mode

Reload configs on file changes:

```bash
./install.sh --watch
```

This uses `inotifywait` to monitor changes and sync immediately.

---

[← Features](features.html) • [Customization →](customization.html)

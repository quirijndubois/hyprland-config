---
layout: home
title: Customization
---

# Customization

Most customization is done through the **Settings overlay** (`Alt + S`), but you can also edit config files directly for deeper control.

## Settings Overlay

Press `Alt + S` to open the settings overlay with a fuzzy search interface.

### Appearance Page

- **Palettes** - 18 color themes (dark and light)
- **Bar design** - 8 styles: default, compact, islands, pills, bold, minimal, clean, hacker
- **Lock screen design** - 5 styles: default, minimal, clock, terminal, split, plus random
- **Bar modules** - Toggle individual modules (Menu, Clock, Battery, CPU, Memory, GPU, Workspaces, Music, Audio, Bluetooth, Network, Sleep Inhibit, System Tray)
- **Font size** - Adjust bar text size while maintaining proportions

### Appearance Tips

- Press `A` on any wallpaper to extract its color palette and apply it system-wide
- Palettes are WCAG-contrast-enforced (text ≥ 7:1, accents ≥ 4.5:1)
- Theme changes animate smoothly over 500ms

## Color Palettes

18 built-in palettes split into dark and light:

**Dark:**
- Catppuccin Mocha, Macchiato, Frappe
- Tokyo Night
- Gruvbox, Gruvbox Light
- Nord, Nord Light
- Dracula
- Rose Pine, Rose Pine Dawn
- One Dark, One Light
- Everforest
- Solarized Dark, Solarized Light

**Light:**
- Catppuccin Latte
- Solarized Light
- Gruvbox Light
- Nord Light
- Rose Pine Dawn
- One Light

## Bar Designs

### Default
Classic, balanced design with clear separation

### Compact
Reduced padding, smaller font, tighter spacing

### Islands
Floating pill-shaped modules with transparent bar background

### Pills
Per-module rounded chips on a transparent bar

### Bold
Thick separators, larger text, high contrast

### Minimal
Sparse, minimal decoration

### Clean
Sans-serif font, modern appearance

### Hacker
Retro terminal-inspired design

## Lock Screen Designs

### Default
Clock + date + username display

### Minimal
Floating animated dots only

### Clock
Oversized 164px time face

### Terminal
Console-style prompt card

### Split
Time on left, password input on right

### Random
Picks a different design on every lock

## Monitor Configuration

Via **Settings → System → Monitor Layout**:

- Enable/disable monitors
- Set resolution and scale
- Set position on virtual screen
- Assign workspaces to monitors

Changes apply live via `hyprctl`.

## System Settings

Via **Settings → System**:

- **Mouse sensitivity** - Adjust pointer speed
- **Natural scroll** - Toggle inverted scrolling
- **Scroll factor** - Adjust scroll speed
- **Blur toggle** - Enable/disable compositor blur (automatically adjusts Kitty opacity)
- **Window layout** - Switch between dwindle, master, scrolling, monocle

## Menu Reordering

In the **Settings** main menu, use `Shift + Up` / `Shift + Down` to reorder menu items. Order is persisted automatically.

## Keyboard-Driven Settings

Navigate with:
- **Arrow keys** - Move between items
- **Enter** - Select/toggle
- **Escape** - Close
- **Type** - Fuzzy search across all items

## Direct File Editing

For advanced customization, edit config files directly:

```
~/.config/quickshell/Theme.qml          # Theme colors and fonts
~/.config/hypr/hyprland.lua             # Hyprland settings
~/.config/kitty/kitty.conf              # Kitty terminal
```

Then reload with `./install.sh --watch` or manually trigger `quickshell` restart.

---

[← Configuration](configuration.html) • [Themes →](themes.html)

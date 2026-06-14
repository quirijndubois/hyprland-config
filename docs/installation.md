---
layout: home
title: Installation
---

# Installation

## 1. Install Dependencies

### Arch Linux

```bash
# Official repositories
sudo pacman -S hyprland kitty awww hypridle hyprshot hyprpicker wl-clipboard cliphist kconfig

# AUR
paru -S quickshell-git
```

> **Important:** Do not install dunst. Quickshell registers itself as the `org.freedesktop.Notifications` D-Bus service. If dunst is installed, mask it to prevent conflicts:
> ```bash
> systemctl --user mask dunst
> ```

### Other Distributions

Ensure you have:
- [Hyprland](https://hyprland.org)
- [Quickshell](https://quickshell.outfoxxed.me/) (built from git)
- [Kitty](https://sw.kovidgoyal.net/kitty/)
- [awww](https://github.com/danyspin97/awww) - wallpaper transitions
- [hypridle](https://github.com/hyprwm/hypridle) - idle management
- [hyprshot](https://github.com/Gustash/hyprshot) - screenshots
- [hyprpicker](https://github.com/hyprwm/hyprpicker) - color picker
- [wl-clipboard](https://github.com/bugaevc/wl-clipboard) - clipboard management
- [cliphist](https://github.com/sentriz/cliphist) - clipboard history

## 2. Clone and Install

```bash
git clone https://github.com/quirijndubois/qaskade.git
cd qaskade
./install.sh
```

This syncs configs for `hypr`, `kitty`, and `quickshell` to `~/.config/`.

### Watch Mode

For development, auto-reload on file changes:

```bash
./install.sh --watch
```

## 3. Firefox Color Sync (Optional)

Enable live palette updates in Firefox using [pywalfox](https://github.com/Frewacom/pywalfox).

### Setup

```bash
# Create conda environment
conda create -n pywalfox python=3.11 -y
conda run -n pywalfox pip install pywalfox Pillow
conda run -n pywalfox pywalfox install
```

### Install Extension

[Firefox - pywalfox](https://addons.mozilla.org/firefox/addon/pywalfox/)

Then restart Firefox. Palette changes in the settings overlay will automatically update Firefox.

> **Note:** System dark/light mode updates immediately for new app launches. Running Qt apps need a restart to pick up new color schemes; GTK apps respond live.

## 4. Add Wallpapers

Drop images into `~/wallpapers/` - they appear immediately in the settings wallpaper picker.

---

[← Features](features.html) • [Keybinds →](keybinds.html)

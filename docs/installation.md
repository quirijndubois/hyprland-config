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

> **Do not install dunst.** Quickshell registers itself as the `org.freedesktop.Notifications` D-Bus service. If dunst is running it will claim that name first and Quickshell won't receive any notifications. Mask it:
> ```bash
> systemctl --user mask dunst
> ```

`kconfig` provides `kwriteconfig6`, used to sync the Qt6 color scheme when the palette changes.

### Other Distributions

See [Requirements](requirements.html) for the full list of needed packages and what each one does.

---

## 2. Clone and Install

```bash
git clone https://github.com/quirijndubois/Qaskade.git
cd Qaskade
./install.sh
```

This syncs `hypr/`, `kitty/`, and `quickshell/` into `~/.config/`. See [Install Script](install-script.html) for details on what it does and what it skips.

### Watch Mode

Auto-sync on file changes during development:

```bash
./install.sh --watch
```

---

## 3. Firefox Color Sync (Optional)

Install [pywalfox](https://github.com/Frewacom/pywalfox) for live palette updates in Firefox.

```bash
conda create -n pywalfox python=3.11 -y
conda run -n pywalfox pip install pywalfox Pillow
conda run -n pywalfox pywalfox install
```

Then install the [Firefox extension](https://addons.mozilla.org/firefox/addon/pywalfox/) and restart Firefox. Palette changes in the settings overlay will update Firefox automatically from that point on.

The `Pillow` package is also used by `extract-palette.py` for wallpaper color extraction - both use the same conda environment.

---

## 4. Wallpapers

Drop images into `~/wallpapers/`. They appear immediately in the settings wallpaper picker.

---

## Next Steps

- [Hyprland Config](hyprland.html) - adjust monitors, programs, and keybinds
- [Hypridle](hypridle.html) - configure idle timeouts
- [Kitty](kitty.html) - understand how terminal theming works
- [Keybinds](keybinds.html) - full keybinding reference

---

[← Overview](index.html) • [Install Script →](install-script.html)

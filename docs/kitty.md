---
layout: home
title: Kitty
---

# Kitty

Kitty is the terminal emulator used by Qaskade. Its config is minimal — most visual properties are managed dynamically by the theme engine.

---

## User Guide

### Launching

`Alt + Q` opens a new Kitty window.

### Background Opacity

Kitty uses a translucent background (`0.6`) by default, which lets the compositor blur show through. When you toggle blur off in **Settings → System**, Qaskade automatically sets opacity to `1.0` to keep the terminal readable. It restores to `0.6` when blur is re-enabled.

You can adjust the base opacity by editing `kitty/kitty.conf`:

```
background_opacity 0.6
```

### Color Scheme

Colors update automatically every time you switch palette in the settings overlay. You don't need to restart Kitty — all open instances update live.

---

## Internals

**File:** `kitty/kitty.conf`

```
background_opacity 0.6
dynamic_background_opacity yes
allow_remote_control yes
listen_on unix:/tmp/kitty-{kitty_pid}
include color_scheme.conf
```

### Remote Control

`allow_remote_control yes` and `listen_on unix:/tmp/kitty-{kitty_pid}` together enable Kitty's remote control API over a per-instance Unix socket at a predictable path.

The `{kitty_pid}` placeholder is expanded by Kitty itself to the process ID, so each instance gets a unique socket like `/tmp/kitty-12345`.

### Live Color Sync

`update-kitty-colors.sh` finds all active Kitty sockets by globbing `/tmp/kitty-*` and sends new colors to each one:

```bash
for socket in /tmp/kitty-*; do
    kitty @ --to "unix:$socket" set-colors --all "$color_file"
done
```

This is called by `Theme.qml` every time the palette changes, updating every open terminal window instantly.

### color_scheme.conf

`include color_scheme.conf` loads a generated color file written by the theme engine. This file is never committed — it lives only in `~/.config/kitty/` and is rewritten on every palette change.

### dynamic_background_opacity

`dynamic_background_opacity yes` allows the opacity to be changed at runtime via remote control, which is how Qaskade sets it to `1.0` when blur is disabled.

---

[← Hypridle](hypridle.html) • [Install Script →](install-script.html)

---
layout: home
title: Hypridle
---

# Hypridle

Hypridle manages idle timeouts - turning off displays and locking the session after periods of inactivity.

---

## User Guide

### Default Behavior

| Idle time | Action |
|---|---|
| 5 minutes | Displays off, keyboard backlight disabled |
| ~17 minutes | Screen locked |

### Sleep / Resume

When the system sleeps (e.g. laptop lid close), the screen locks immediately before sleep and the keyboard backlight re-enables on wake.

### Adjusting Timeouts

Edit `hypr/hypridle.conf` and change the `timeout` values (in seconds), then re-run `./install.sh` to sync.

---

## Internals

**File:** `hypr/hypridle.conf`

```ini
general {
    before_sleep_cmd = qs ipc call lock lock && solaar config "MX Mechanical Mini" backlight Disabled
    unlock_cmd       = solaar config "MX Mechanical Mini" backlight Enabled
}

listener {
    timeout    = 300
    on-timeout = hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })' && solaar config "MX Mechanical Mini" backlight Disabled
    on-resume  = hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })'  && solaar config "MX Mechanical Mini" backlight Enabled
}

listener {
    timeout    = 1000
    on-timeout = qs ipc call lock lock
}
```

### before_sleep_cmd

Runs immediately when the system suspends. Uses Quickshell IPC (`qs ipc call lock lock`) to engage the Wayland session lock before the system sleeps, ensuring the screen is locked on wake.

Also uses `solaar` to disable the `MX Mechanical Mini` keyboard backlight on sleep and re-enable it on wake. The `solaar` commands are specific to this hardware - remove or adapt them for your setup.

### Display Listener (300s)

At 5 minutes idle, `hyprctl dispatch hl.dsp.dpms(...)` turns off all connected displays via DPMS. On resume, the same command re-enables them.

### Lock Listener (1000s)

At ~17 minutes idle, `qs ipc call lock lock` triggers the Quickshell lock screen via IPC (same path as `Alt + Delete`).

---

[← Hyprland Config](hyprland.html) • [Kitty →](kitty.html)

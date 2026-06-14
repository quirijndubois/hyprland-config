---
layout: home
title: Bar Modules
---

# Bar Modules

Each module is an independent QML file extending `BarText` (or `Item` for graphical modules). All modules can be toggled independently via **Settings → Appearance**.

---

## CPU (`CpuModule.qml`)

**User:** Shows aggregate usage as `cpu 42%`. Hover to see a per-core bar chart and top 5 processes by CPU.

**Internals:** Polls `/proc/stat` every 2s via `grep '^cpu' /proc/stat`. The first line is the aggregate; remaining lines are per-core. Usage delta:

```
usage = (dTotal - dIdle) / dTotal * 100
```

where `dIdle = idle + iowait` and `dTotal` is sum of all fields. Previous snapshot is stored in `prevStat` / `coreStat`. Top processes use `ps --sort=-pcpu`, run only while the popup is open, refreshed every 3s.

---

## Memory (`MemoryModule.qml`)

**User:** Shows used memory as `mem 8.1G`. Hover to see a usage bar and top 5 processes by RSS.

**Internals:** Reads `/proc/meminfo` every 5s with `awk '/MemTotal:/{t=$2} /MemAvailable:/{a=$2}'`. `MemAvailable` accounts for page cache and reclaimable slabs, giving a realistic "actually available" figure. Used = Total - Available. Top processes use `ps --sort=-rss` in MB, run only while the popup is open.

---

## GPU (`GpuModule.qml`)

**User:** Shows NVIDIA GPU utilization as `gpu 34%`. Hover for utilization bar + VRAM usage + top GPU processes by VRAM.

**Internals:** Runs `nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits` every 2s. Falls back to `0, 0, 0` if `nvidia-smi` is absent. Top GPU processes use `nvidia-smi --query-compute-apps=name,used_memory`, run only while the popup is open, refreshed every 4s. Bar color thresholds: blue → yellow at 50%, yellow → red at 80%.

---

## Battery (`BatteryModule.qml`)

**User:** Shows `bat 87%`, `bat +87%` (charging), or `bat =87%` (full). Hover for a percentage bar and time remaining/to full.

**Internals:** Uses `Quickshell.Services.UPower` - Quickshell's native UPower D-Bus binding. The `UPower.displayDevice` represents the primary battery. Percentage is read from `device.percentage` (normalized to 0–100 with an energy fallback if the value is in 0–1 range). Time remaining comes from `device.timeToEmpty` / `device.timeToFull` (seconds), formatted to `Xh Ym`. State enum `UPowerDeviceState` drives the prefix and bar color: green → yellow at 40%, yellow → red at 20%.

---

## Clock (`ClockModule.qml`)

**User:** Shows `HH:MM`. Hover to see the full date (`Wednesday, June 14`).

**Internals:** A 1s `Timer` updates two strings using Qt's date formatting:
```qml
Qt.formatTime(new Date(), "hh:mm")
Qt.formatDate(new Date(), "dddd, MMMM d")
```
No system calls - all in-process.

---

## Audio (`AudioModule.qml`)

**User:** Shows `vol 72%` or `vol mute`. Hover to see a master volume slider with a draggable knob and per-app volume sliders with live peak meters. Right-click opens `pavucontrol`.

**Internals:** Uses Quickshell's PipeWire binding. `Pipewire.defaultAudioSink` is kept alive with `PwObjectTracker`. Per-app streams are collected by watching `Pipewire.nodes` for `PwNodeType.AudioOutStream`. Node changes are debounced with `Qt.callLater` to batch rapid updates into a single refresh.

Peak meters use `PwNodePeakMonitor` per stream - enabled only when `BarHover.activeModule === "audio"`. Bar turns red above 85% peak. Master volume slider allows dragging to 150% (red fill above 100%). Popup height is dynamic: 104px with no streams, 264px with streams.

---

## Music / MPRIS (`MusicModule.qml`)

**User:** Shows 5 animated dancing bars while music plays, static short bars when paused, hidden when stopped. Hover for track title, artist, progress bar with seek, and transport controls.

**Internals:** Uses `Quickshell.Services.Mpris`. Player selection prefers a playing player, falls back to any player. A 50ms `Timer` drives 5 amplitude values using offset sine waves:

```js
amps[i] = base_i + range_i * Math.abs(Math.sin(phase * freq_i + offset_i))
```

Each bar has a different frequency and offset to avoid lockstep movement. Seek position is tracked locally with a 500ms `Timer` that increments `displayPos`, avoiding polling the player process constantly.

---

## Bluetooth (`BluetoothModule.qml`)

**User:** Shows `bt off`, `bt on`, or `bt 2` (connected device count). Hover to see connected device names and a toggle. Click opens `blueman-manager`.

**Internals:** Uses Quickshell's native `Quickshell.Bluetooth` binding - no shell commands. `Bluetooth.defaultAdapter` exposes the adapter state and device list. Connected device count is maintained by a `Repeater` over `defaultAdapter.devices`, watching each device's `connected` property with `onConnChanged`. `refreshCount()` is called whenever any device's connection state changes.

Toggle in the popup sets `Bluetooth.defaultAdapter.enabled` directly.

---

## Network (`NetworkModule.qml`)

**User:** Shows WiFi SSID (truncated to 9 chars), `eth` for Ethernet, or `no net`. Hover for full SSID and IP address. Click opens `nm-connection-editor`.

**Internals:** Two shell processes run at startup and every 10s:

- **SSID/type:** `iwgetid -r` gets the WiFi SSID. If empty, `nmcli dev` checks for an active ethernet connection.
- **IP:** `ip -4 addr show $(ip route | awk '/default/{print $5; exit}')` - resolves the default route's interface then reads its IPv4 address.

SSID is stored in full (`ssidFull`) for the popup, displayed truncated in the bar.

---

## Sleep Inhibit (`InhibitModule.qml` + `InhibitState.qml`)

**User:** A moon icon (☾) in the bar. Dim when inactive, yellow when active. Click to toggle. Prevents the system from sleeping or locking while active.

**Internals:** `InhibitState.qml` is a `pragma Singleton` holding a single `inhibited: bool`. `InhibitModule.qml` reads and writes it on click.

The actual inhibition uses Quickshell's `IdleInhibitor` (from `Quickshell.Wayland._IdleInhibitor`), which implements the `zwp_idle_inhibit_manager_v1` Wayland protocol:

```qml
IdleInhibitor {
    enabled: InhibitState.inhibited
    window:  root.Window.window
}
```

When `enabled` is true, the compositor is notified via the protocol and suppresses all idle timeouts - no `systemd-inhibit` or shell commands involved.

---

## System Tray (`TrayModule.qml`)

**User:** Shows 16×16 icons for any `StatusNotifierItem` application. Left-click activates the item, right-click opens its context menu.

**Internals:** Uses Quickshell's `SystemTray.items` model. The tricky part is icon resolution - Qt's `image://icon/` provider is unreliable for tray icons, so `TrayModule` implements a manual fallback chain:

1. Absolute path (`/...`) → `file://` URL
2. `file://` URL → used directly
3. Non-`image://icon/` URL → used directly
4. `image://icon/name?path=dir` → tries `dir/name.png`, then `dir/name.svg`, then strips the path hint
5. Named icon → probes 12 specific directories in Papirus and Breeze icon themes (panel, status, apps, actions, devices, places contexts at 16px) in order, then falls back to the `image://icon/` provider, then gives up

The `_fb` (fallback index) counter increments on each `Image.Error` status until a source loads or all candidates are exhausted.

---

## Workspaces (`WorkspacesModule.qml`)

**User:** Numbered workspace buttons for the current monitor. Click to switch. Active workspace has an animated sliding highlight.

**Internals:** Uses `Quickshell.Hyprland.workspaces` as the Repeater model, filtered by `modelData.monitor === root.monitor`. The animated highlight is a `Rectangle` whose `x` follows `highlightX` with a 200ms `OutCubic` `NumberAnimation`. `highlightX` updates in `onIsFocusedChanged` via `Qt.callLater` to ensure the delegate's layout is settled before reading its position.

The workspaces pill doubles as the notification center - hovering opens a popup with the 5 most recent notifications (see [Notifications](notifications.html)).

---

## App Launcher (`list_apps.py`)

**User:** Used internally by the Settings overlay's **Apps** page. Not a bar module - runs in the background when the apps page opens.

**Internals:** Scans `/usr/share/applications/*.desktop` and `~/.local/share/applications/*.desktop`. For each file, parses only the `[Desktop Entry]` section, reading `Name`, `Exec`, `Icon`, `Terminal`, `NoDisplay`, and `Type`. Filters out entries with `NoDisplay=true` or `Type != Application`. Outputs one tab-separated line per app:

```
Name\tExec\tIcon\tTerminal
```

Results are sorted case-insensitively. The settings overlay reads this output, renders app icons, and launches entries by executing the `Exec` field (with `%f`, `%u`, etc. placeholders stripped).

---

[← Bar](bar.html) • [Notifications →](notifications.html)
